import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:final_project/models/student_models.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check connection method
  Future<bool> checkConnection() async {
    try {
      await _firestore.runTransaction((transaction) async {
        return true;
      });
      return true;
    } catch (e) {
      print('Connection error: $e');
      return false;
    }
  }

  // Authentication methods
  Future<UserCredential> loginUser(String email, String password) async {
    try {
      // Check connection first
      bool isConnected = await checkConnection();
      if (!isConnected) {
        throw FirebaseException(
          plugin: 'firebase_service',
          code: 'network-error',
          message: 'No internet connection. Please check your network.',
        );
      }

      // First authenticate with Firebase
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Then check if user exists in Firestore
      final userDoc = await _firestore
          .collection('students')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        await _auth.signOut(); // Sign out if no Firestore record exists
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user record found. Please register first.',
        );
      }

      print('Login successful for user: ${userCredential.user!.email}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        case 'user-disabled':
          errorMessage = 'This user account has been disabled.';
          break;
        default:
          errorMessage = 'An error occurred: ${e.message}';
      }
      throw FirebaseAuthException(
        code: e.code,
        message: errorMessage,
      );
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  // Registration methods
  Future<void> registerStudent({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Check connection first
      bool isConnected = await checkConnection();
      if (!isConnected) {
        throw FirebaseException(
          plugin: 'firebase_service',
          code: 'network-error',
          message: 'No internet connection. Please check your network.',
        );
      }

      // Create auth user
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create a Student object
      Student newStudent = Student(
        firstName: name.split(' ')[0],
        lastName: name.split(' ').length > 1
            ? name.split(' ').sublist(1).join(' ')
            : '',
        email: email,
      );

      // Save user data to Firestore
      await _firestore
          .collection('students')
          .doc(userCredential.user!.uid)
          .set(newStudent.toJson())
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Registration timed out. Please try again.');
        },
      );

      print(
          'User registered successfully with ID: ${userCredential.user!.uid}');
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: $e');
      rethrow;
    } on TimeoutException catch (e) {
      print('Timeout Error: $e');
      rethrow;
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Update student profile
  Future<void> updateStudentProfile(String userId, Student student) async {
    try {
      await _firestore
          .collection('students')
          .doc(userId)
          .update(student.toJson());
    } catch (e) {
      rethrow;
    }
  }

  // Get student profile
  Future<Student> getStudentProfile(String userId) async {
    try {
      final doc = await _firestore.collection('students').doc(userId).get();
      if (!doc.exists) {
        throw Exception('Student profile not found');
      }
      return Student.fromJson(doc.data()!);
    } catch (e) {
      rethrow;
    }
  }

  // Add a project to student profile
  Future<void> addProject(String userId, Project project) async {
    try {
      await _firestore.collection('students').doc(userId).update({
        'projects': FieldValue.arrayUnion([project.toJson()])
      });
    } catch (e) {
      rethrow;
    }
  }

  // Add a course to student profile
  Future<void> addCourse(String userId, Course course) async {
    try {
      await _firestore.collection('students').doc(userId).update({
        'courses': FieldValue.arrayUnion([course.toJson()])
      });
    } catch (e) {
      rethrow;
    }
  }
}
