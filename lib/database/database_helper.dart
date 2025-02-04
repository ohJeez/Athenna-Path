import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/employee_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  static const String dbName = 'athenna_path.db';
  static late String dbPath; // Make it late final

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Get the proper path
    final dbFolder = await getDatabasesPath();
    dbPath = join(dbFolder, dbName);

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Add this debug print
    final dbFolder = await getDatabasesPath();
    print('\n=== Database Location ===');
    print('Default database folder: $dbFolder');
    print('Current database path: $dbPath');

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _createTables,
      onOpen: (db) async {
        // Ensure tables exist
        await _createTables(db, 1);
        print('Database opened at: $dbPath');
      },
    );
  }

  Future<void> _createTables(Database db, int version) async {
    print('Creating/Verifying tables...');

    // Create companies table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS companies (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        companyName TEXT NOT NULL,
        foundedYear TEXT NOT NULL,
        email TEXT NOT NULL,
        companyType TEXT NOT NULL,
        password TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // Create employees table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS employees (
        emp_id INTEGER PRIMARY KEY AUTOINCREMENT,
        e_firstname TEXT NOT NULL,
        e_lastname TEXT NOT NULL,
        e_email TEXT NOT NULL,
        e_phone INTEGER NOT NULL,
        e_position TEXT NOT NULL,
        e_department TEXT NOT NULL,
        e_joinDate TEXT NOT NULL,
        e_profilepicture TEXT NOT NULL,
        company_id INTEGER NOT NULL,
        Field11 INTEGER
      )
    ''');

    // Create jobs table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS jobs (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        location TEXT NOT NULL,
        company TEXT NOT NULL,
        salary_range INTEGER,
        required_skills TEXT,
        experience_level TEXT,
        qualification TEXT,
        deadline TEXT,
        employment_type TEXT,
        date_posted TEXT,
        company_id INTEGER,
        FOREIGN KEY(company_id) REFERENCES companies(id)
      )
    ''');

    print('Tables created/verified successfully');
    await _verifyTables(db);
  }

  Future<void> _verifyTables(Database db) async {
    try {
      final tables = await db
          .query('sqlite_master', where: 'type = ?', whereArgs: ['table']);

      print('\nExisting tables:');
      for (var table in tables) {
        print('- ${table['name']}');
      }
    } catch (e) {
      print('Error verifying tables: $e');
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
      whereArgs: [email.toLowerCase()],
    );
    return result.isNotEmpty;
  }

  // Updated method to insert company with auto-incrementing ID
  Future<int> insertCompany(Map<String, dynamic> company) async {
    try {
      final db = await database;
      print('Inserting company: $company');
      // Remove id if present as it's auto-incrementing
      company.remove('id');
      final id = await db.insert('companies', company);
      print('Company inserted with ID: $id');
      return id;
    } catch (e) {
      print('Error inserting company: $e');
      throw Exception('Failed to insert company: $e');
    }
  }

  // Helper method to get company by email and password
  Future<Map<String, dynamic>?> getCompany(
      String email, String password) async {
    try {
      final db = await database;
      final results = await db.query(
        'companies',
        where: 'email = ? AND password = ?',
        whereArgs: [email.toLowerCase(), password],
      );

      if (results.isEmpty) {
        return null;
      }

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

  // Add this debug method
  Future<void> debugCompanyData(String email) async {
    try {
      final db = await database;
      final results = await db.query(
        'companies',
        where: 'email = ?',
        whereArgs: [email.toLowerCase()],
      );

      if (results.isNotEmpty) {
        print('\n=== Company Debug Data ===');
        print('Email: $email');
        print('Found company data: ${results.first}');
        print('=========================\n');
      } else {
        print('\n=== Company Not Found ===');
        print('Email: $email');
        print('=========================\n');
      }
    } catch (e) {
      print('Debug Error: $e');
    }
  }

  // Helper methods for jobs
  Future<List<Map<String, dynamic>>> queryJobs() async {
    final Database db = await database;
    return await db.query('jobs');
  }

  // Updated method to insert job with proper foreign key
  Future<void> insertJob(Map<String, dynamic> job) async {
    try {
      final db = await database;
      await db.insert('jobs', job);
    } catch (e) {
      print('Error inserting job: $e');
      throw Exception('Failed to insert job: $e');
    }
  }

  Future<void> updateJob(Map<String, dynamic> job) async {
    final Database db = await database;
    await db.update(
      'jobs',
      job,
      where: 'id = ?',
      whereArgs: [job['id']],
    );
  }

  Future<void> deleteJob(String id) async {
    final Database db = await database;
    await db.delete(
      'jobs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> resetDatabase() async {
    final String path = join(await getDatabasesPath(), dbName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
    await database; // This will recreate the database
  }

  // Debug method to verify database content
  Future<void> debugPrintAllCompanies() async {
    try {
      final db = await database;
      final companies = await db.query('companies');
      print('\n=== All Companies in Database ===');
      for (var company in companies) {
        print('Company: ${company['companyName']}, Email: ${company['email']}');
      }
      print('===============================\n');
    } catch (e) {
      print('Error printing companies: $e');
    }
  }

  // Updated method to insert employee with auto-incrementing ID
  Future<int> insertEmployee(Map<String, dynamic> employee) async {
    try {
      final db = await database;
      // Remove emp_id from map as it's auto-incrementing
      employee.remove('emp_id');
      return await db.insert('employees', employee);
    } catch (e) {
      print('Error inserting employee: $e');
      throw Exception('Failed to insert employee: $e');
    }
  }

  // Debug method to check database state
  Future<void> debugDatabase() async {
    try {
      final db = await database;
      print('\n=== Database Debug Info ===');

      final tables = await db
          .query('sqlite_master', where: 'type = ?', whereArgs: ['table']);

      print('Tables found: ${tables.length}');
      for (var table in tables) {
        print('Table: ${table['name']}');
        print('SQL: ${table['sql']}');
      }

      if (tables.any((table) => table['name'] == 'companies')) {
        final companies = await db.query('companies');
        print('\nCompanies found: ${companies.length}');
        for (var company in companies) {
          print('Company: $company');
        }
      }

      print('=== End Debug Info ===\n');
    } catch (e) {
      print('Debug Error: $e');
    }
  }
}
