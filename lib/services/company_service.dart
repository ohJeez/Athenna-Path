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
  final _uuid = const Uuid();
  Company? _currentCompany;

  // Hash password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Register company (Local DB)
  Future<void> registerCompany({
    required String email,
    required String password,
    required String companyName,
    required String foundedYear,
    required String adminName,
    required String companyType,
  }) async {
    try {
      final exists = await _dbHelper.companyExists(email);
      if (exists) {
        throw Exception('A company with this email already exists');
      }

      final hashedPassword = _hashPassword(password);
      final company = Company(
        id: _uuid.v4(),
        companyName: companyName,
        foundedYear: foundedYear,
        adminName: adminName,
        email: email.toLowerCase(),
        companyType: companyType,
        password: hashedPassword,
        createdAt: DateTime.now().toIso8601String(),
      );

      print('Registering new company: ${company.companyName}');
      await _dbHelper.insertCompany(company.toMap());
      print('Company registered successfully');
    } catch (e) {
      print('Registration Error: $e');
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Login company
  Future<Company> loginCompany({
    required String email,
    required String password,
  }) async {
    try {
      print('\n=== Login Attempt ===');
      print('Email: $email');

      final hashedPassword = _hashPassword(password);
      print('Password hashed successfully');

      final companyData = await _dbHelper.getCompany(email, hashedPassword);

      if (companyData == null) {
        print('No matching company found in database');
        throw Exception('Invalid email or password');
      }

      print('Company found in database');
      final company = Company.fromMap(companyData);

      // Store the company but remove sensitive data
      _currentCompany = company.toSafeCompany();

      print('Login successful for: ${company.companyName}');
      return _currentCompany!;
    } catch (e) {
      print('Login Error: $e');
      throw Exception('Login failed: ${e.toString()}');
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

  // Set current company
  Future<void> setCurrentCompany(Company company) async {
    _currentCompany = company;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('company_id', company.id);
  }

  // Clear current company (for logout)
  Future<void> logout() async {
    _currentCompany = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('company_id');
  }

  // Check if current user is a company
  Future<bool> isCompanyUser(String id) async {
    if (_currentCompany != null) {
      return true;
    }

    final db = await _dbHelper.database;
    final result = await db.query(
      'companies',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty;
  }

  // Get company by ID
  Future<Company> getCompanyById(String id) async {
    final db = await _dbHelper.database;
    final companies = await db.query(
      'companies',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (companies.isEmpty) {
      throw Exception('Company not found');
    }

    return Company.fromMap(companies.first);
  }

  // Add this method to check login status
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
}
