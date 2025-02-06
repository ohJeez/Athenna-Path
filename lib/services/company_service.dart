import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/company_model.dart';
import '../models/employee_model.dart';
import '../models/job-models.dart';

class CompanyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Company? _currentCompany;

  // Check if email exists
  Future<bool> checkEmailExists(String email) async {
    try {
      final result = await _firestore
          .collection('companies')
          .where('email', isEqualTo: email.toLowerCase())
          .get();
      return result.docs.isNotEmpty;
    } catch (e) {
      print('Error checking email: $e');
      throw Exception('Failed to check email: $e');
    }
  }

  // Register company
  Future<void> registerCompany({
    required String email,
    required String password,
    required String companyName,
    required String foundedYear,
    required String companyType,
    String? adminName,
  }) async {
    try {
      // Create auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create company document
      await _firestore
          .collection('companies')
          .doc(userCredential.user!.uid)
          .set({
        'companyName': companyName,
        'email': email,
        'foundedYear': foundedYear,
        'companyType': companyType,
        'adminName': adminName,
        'userType': 'company',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to register company: $e');
    }
  }

  // Login company
  Future<Company> loginCompany(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get company data from Firestore
      final doc = await _firestore
          .collection('companies')
          .doc(userCredential.user!.uid)
          .get();

      if (!doc.exists) throw Exception('Company data not found');

      final data = doc.data()!;
      return Company.fromMap({...data, 'id': doc.id});
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  // Get employees
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
  Company? getCurrentCompany() => _currentCompany;

  // Clear current company (for logout)
  Future<void> clearCurrentCompany() async {
    _currentCompany = null;
    await _auth.signOut();
  }

  // Check if current user is a company
  Future<bool> isCompanyUser(String uid) async {
    final doc = await _firestore.collection('companies').doc(uid).get();
    return doc.exists;
  }

  // Get company by ID
  Future<Company> getCompanyById(String uid) async {
    try {
      final doc = await _firestore.collection('companies').doc(uid).get();
      if (!doc.exists) {
        throw Exception('Company not found');
      }
      return Company.fromFirestore(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get company: $e');
    }
  }

  // Check login status
  Future<bool> isLoggedIn() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final company = await getCompanyById(user.uid);
      _currentCompany = company;
      return true;
    } catch (e) {
      return false;
    }
  }

  // Update company
  Future<void> updateCompany(Company company) async {
    try {
      await _firestore
          .collection('companies')
          .doc(company.id)
          .update(company.toMap());

      if (_currentCompany?.id == company.id) {
        _currentCompany = company;
      }
    } catch (e) {
      throw Exception('Failed to update company: $e');
    }
  }

  // Get company by email
  Future<Company?> getCompanyByEmail(String email) async {
    try {
      final snapshot = await _firestore
          .collection('companies')
          .where('email', isEqualTo: email.toLowerCase())
          .get();

      if (snapshot.docs.isNotEmpty) {
        return Company.fromFirestore(snapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      print('Error getting company by email: $e');
      return null;
    }
  }

  // Add job
  Future<void> addJob(Job job) async {
    try {
      final docRef = await _firestore.collection('jobs').add(job.toMap());
      print('Job added with ID: ${docRef.id}');
    } catch (e) {
      print('Error adding job: $e');
      throw Exception('Failed to add job: $e');
    }
  }

  // Get jobs for company
  Future<List<Job>> getCompanyJobs(String companyId) async {
    try {
      final snapshot = await _firestore
          .collection('jobs')
          .where('company_id', isEqualTo: companyId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID to the data
        return Job.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get jobs: $e');
    }
  }

  // Update job
  Future<void> updateJob(Job job) async {
    try {
      await _firestore.collection('jobs').doc(job.id).update(job.toMap());
    } catch (e) {
      throw Exception('Failed to update job: $e');
    }
  }

  // Delete job
  Future<void> deleteJob(String jobId) async {
    await _firestore.collection('jobs').doc(jobId).delete();
  }

  // Stream company jobs
  Stream<List<Job>> streamCompanyJobs(String companyId) {
    return _firestore
        .collection('jobs')
        .where('companyId', isEqualTo: companyId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Job.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Get company profile
  Future<Company> getCompanyProfile(String companyId) async {
    final doc = await _firestore.collection('companies').doc(companyId).get();
    if (!doc.exists) throw Exception('Company not found');
    return Company.fromMap({...doc.data()!, 'id': doc.id});
  }
}
