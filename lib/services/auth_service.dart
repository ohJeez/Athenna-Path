import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register company
  Future<UserCredential> registerCompany(
      String email, String password, Map<String, String> companyData) async {
    try {
      // Create auth user
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create company document
      await _firestore
          .collection('companies')
          .doc(userCredential.user!.uid)
          .set({
        'id': userCredential.user!.uid,
        'companyName': companyData['companyName'],
        'email': email,
        'foundedYear': companyData['foundedYear'],
        'companyType': companyData['companyType'],
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } catch (e) {
      throw Exception('Failed to register company: $e');
    }
  }

  // Check if user is company
  Future<bool> isCompanyUser(String uid) async {
    try {
      final doc = await _firestore.collection('companies').doc(uid).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }
}
