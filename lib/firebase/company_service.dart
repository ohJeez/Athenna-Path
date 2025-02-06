import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register company
  Future<void> registerCompany({
    required String email,
    required String password,
    required String companyName,
    required String foundedYear,
    required String companyType,
    String? adminName, // Make adminName optional
  }) async {
    try {
      // First check if email already exists
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) {
        throw Exception('An account already exists for that email.');
      }

      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Failed to create user account.');
      }

      // Add company details to Firestore
      await _firestore
          .collection('companies')
          .doc(userCredential.user!.uid)
          .set({
        'companyName': companyName,
        'foundedYear': foundedYear,
        'adminName': adminName,
        'email': email,
        'companyType': companyType,
        'userType': 'company',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Send email verification
      await userCredential.user!.sendEmailVerification();
    } catch (e) {
      throw Exception('Failed to register company: $e');
    }
  }

  // Login company
  Future<UserCredential> loginCompany({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Verify if the user is a company
      DocumentSnapshot companyDoc = await _firestore
          .collection('companies')
          .doc(userCredential.user!.uid)
          .get();

      if (!companyDoc.exists) {
        await _auth.signOut();
        throw Exception('No company account found for this email');
      }

      Map<String, dynamic> data = companyDoc.data() as Map<String, dynamic>;
      if (data['userType'] != 'company') {
        await _auth.signOut();
        throw Exception('This account is not registered as a company');
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided.');
      } else {
        throw Exception('Error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  // Get current company data
  Future<Map<String, dynamic>> getCurrentCompanyData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      DocumentSnapshot companyDoc =
          await _firestore.collection('companies').doc(user.uid).get();

      if (!companyDoc.exists) throw Exception('Company data not found');

      return companyDoc.data() as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get company data: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
