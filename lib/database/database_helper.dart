import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/employee_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'athenna_path.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE companies(
        id TEXT PRIMARY KEY,
        companyName TEXT NOT NULL,
        foundedYear TEXT NOT NULL,
        adminName TEXT NOT NULL,
        email TEXT NOT NULL,
        companyType TEXT NOT NULL,
        password TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE employees(
        id TEXT PRIMARY KEY,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        email TEXT NOT NULL,
        phoneNumber TEXT NOT NULL,
        position TEXT NOT NULL,
        department TEXT NOT NULL,
        joinDate TEXT NOT NULL,
        profilePicture TEXT,
        companyId TEXT NOT NULL,
        FOREIGN KEY (companyId) REFERENCES companies (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE skills(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        employeeId TEXT NOT NULL,
        name TEXT NOT NULL,
        level INTEGER NOT NULL,
        FOREIGN KEY (employeeId) REFERENCES employees (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE jobs(
        id TEXT PRIMARY KEY,
        title TEXT,
        company TEXT,
        description TEXT,
        location TEXT,
        employmentType TEXT,
        image TEXT,
        datePosted TEXT,
        salaryRange TEXT,
        requiredSkills TEXT,
        experienceLevel TEXT,
        qualification TEXT,
        deadline TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE jobs(
          id TEXT PRIMARY KEY,
          title TEXT,
          company TEXT,
          description TEXT,
          location TEXT,
          employmentType TEXT,
          image TEXT,
          datePosted TEXT,
          salaryRange TEXT,
          requiredSkills TEXT,
          experienceLevel TEXT,
          qualification TEXT,
          deadline TEXT
        )
      ''');
    }
  }

  Future<void> deleteDatabase() async {
    String path = join(await getDatabasesPath(), 'athenna_path.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  // Helper method to check if a company exists
  Future<bool> companyExists(String email) async {
    final db = await database;
    final result = await db.query(
      'companies',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  // Helper method to insert company
  Future<void> insertCompany(Map<String, dynamic> company) async {
    final db = await database;
    await db.insert('companies', company,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Helper method to get company by email and password
  Future<Map<String, dynamic>?> getCompany(
      String email, String password) async {
    try {
      final db = await database;
      print('\n=== Database Query ===');
      print('Searching for email: $email');
      print('With password hash: $password');

      // First check if email exists
      final emailCheck = await db.query(
        'companies',
        where: 'email = ?',
        whereArgs: [email.toLowerCase()],
      );

      if (emailCheck.isEmpty) {
        print('ERROR: No company found with email: $email');
        return null;
      }

      print('Email found in database');
      print('Stored company data: ${emailCheck.first}');

      // Then check password
      final results = await db.query(
        'companies',
        where: 'email = ? AND password = ?',
        whereArgs: [email.toLowerCase(), password],
      );

      if (results.isEmpty) {
        print('ERROR: Password mismatch for email: $email');
        print('Stored password hash: ${emailCheck.first['password']}');
        print('Provided password hash: $password');
        return null;
      }

      print('Login successful!');
      print('=== Query Complete ===\n');
      return results.first;
    } catch (e) {
      print('Database Error: $e');
      return null;
    }
  }

  // Helper method to print all companies (for debugging)
  Future<void> printAllCompanies() async {
    try {
      final db = await database;
      final results = await db.query('companies');
      print('\n--- All Companies in Database ---');
      for (var company in results) {
        print('Company: ${company.toString()}');
      }
      print('--------------------------------\n');
    } catch (e) {
      print('Error printing companies: $e');
    }
  }

  // Add this method to help with debugging
  Future<void> verifyCompanyData(String email) async {
    try {
      final db = await database;
      final results = await db.query(
        'companies',
        where: 'email = ?',
        whereArgs: [email.toLowerCase()],
      );

      if (results.isNotEmpty) {
        print('\n=== Company Data Verification ===');
        print('Company found with email: $email');
        var company = Map<String, dynamic>.from(results.first);
        // Remove password before printing
        var passwordHash = company['password'];
        company.remove('password');
        print('Stored data: $company');
        print('Password hash length: ${passwordHash.length}');
        print('=== Verification Complete ===\n');
      }
    } catch (e) {
      print('Verification Error: $e');
    }
  }
}
