import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../database/database_helper.dart';
import '../models/company_model.dart';
import '../models/employee_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompanyService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Company? _currentCompany;

  // Hash password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Register company
  Future<void> registerCompany({
    required String email,
    required String password,
    required String companyName,
    required String foundedYear,
    required String companyType,
  }) async {
    try {
      final company = Company(
        companyName: companyName,
        foundedYear: foundedYear,
        email: email.toLowerCase(),
        companyType: companyType,
        password: password,
        createdAt: DateTime.now().toIso8601String(),
      );

      final db = await _dbHelper.database;

      // Check if email already exists
      final existingCompany = await db.query(
        'companies',
        where: 'email = ?',
        whereArgs: [email.toLowerCase()],
      );

      if (existingCompany.isNotEmpty) {
        throw Exception('Email already registered');
      }

      final id = await db.insert('companies', company.toJson());
      print('Company registered with ID: $id');

      // Save company ID to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('company_id', id.toString());
    } catch (e) {
      print('Registration Error: $e');
      throw Exception('Registration failed: $e');
    }
  }

  // Login company
  Future<Company> loginCompany({
    required String email,
    required String password,
  }) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        'companies',
        where: 'email = ? AND password = ?',
        whereArgs: [email.toLowerCase(), password],
      );

      if (results.isEmpty) {
        throw Exception('Invalid email or password');
      }

      final company = Company.fromMap(results.first);
      _currentCompany = company;

      // Save company ID to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('company_id', company.id.toString());

      return company;
    } catch (e) {
      print('Login Error: $e');
      throw Exception('Login failed: $e');
    }
  }

  // Get employees (from Firebase)
  Future<Map<String, List<Employee>>> getEmployeesByDepartment(
      String companyId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('students')
          .where('companyId', isEqualTo: companyId)
          .get();

      Map<String, List<Employee>> departmentMap = {};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final employee = Employee.fromJson({
          'id': doc.id,
          ...data,
        });

        if (!departmentMap.containsKey(employee.department)) {
          departmentMap[employee.department] = [];
        }
        departmentMap[employee.department]!.add(employee);
      }

      return departmentMap;
    } catch (e) {
      throw Exception('Failed to load employees: $e');
    }
  }

  // Get current company
  Company? getCurrentCompany() {
    return _currentCompany;
  }

  // Clear current company (for logout)
  Future<void> clearCurrentCompany() async {
    _currentCompany = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('company_id');
  }

  // Check if current user is a company
  Future<bool> isCompanyUser(String uid) async {
    if (_currentCompany != null) {
      return true;
    }

    final db = await _dbHelper.database;
    final result = await db.query(
      'companies',
      where: 'id = ?',
      whereArgs: [int.parse(uid)],
    );
    return result.isNotEmpty;
  }

  // Get company by ID
  Future<Company> getCompanyById(String uid) async {
    final db = await _dbHelper.database;
    final companies = await db.query(
      'companies',
      where: 'id = ?',
      whereArgs: [int.parse(uid)],
    );

    if (companies.isEmpty) {
      throw Exception('Company not found');
    }

    return Company.fromMap(companies.first);
  }

  // Check login status
  Future<bool> isLoggedIn() async {
    if (_currentCompany != null) return true;

    final prefs = await SharedPreferences.getInstance();
    final companyId = prefs.getString('company_id');

    if (companyId != null) {
      try {
        final company = await getCompanyById(companyId);
        _currentCompany = company;
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  // Update company
  Future<void> updateCompany(Company company) async {
    try {
      if (company.id == null) {
        throw Exception('Cannot update company without ID');
      }

      final db = await _dbHelper.database;
      final count = await db.update(
        'companies',
        company.toJson(),
        where: 'id = ?',
        whereArgs: [company.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (count == 0) {
        throw Exception('Company not found');
      }

      // Update current company if it's the logged-in company
      if (_currentCompany?.id == company.id) {
        _currentCompany = company;
      }

      print('Company updated successfully: ${company.companyName}');
    } catch (e) {
      print('Error updating company: $e');
      throw Exception('Failed to update company: $e');
    }
  }

  // Get company by email
  Future<Company?> getCompanyByEmail(String email) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        'companies',
        where: 'email = ?',
        whereArgs: [email.toLowerCase()],
      );

      if (results.isNotEmpty) {
        return Company.fromMap(results.first);
      }
      return null;
    } catch (e) {
      print('Error getting company by email: $e');
      return null;
    }
  }
}
