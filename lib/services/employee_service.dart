import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_models.dart';

class EmployeeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Student>> getEmployees() async {
    try {
      print('Fetching students from Firebase...');

      final QuerySnapshot snapshot =
          await _firestore.collection('students').get();

      print('Found ${snapshot.docs.length} students');

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        print('Processing student: ${data['firstName']} ${data['lastName']}');
        return Student.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching students: $e');
      throw Exception('Failed to load students: $e');
    }
  }

  Future<List<Student>> getStudentsByDepartment(String department) async {
    try {
      print('Fetching students for department: $department');

      final QuerySnapshot snapshot = await _firestore
          .collection('students')
          .where('department', isEqualTo: department)
          .get();

      print('Found ${snapshot.docs.length} students in $department');

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Student.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching students by department: $e');
      throw Exception('Failed to load students by department: $e');
    }
  }

  Stream<List<Student>> streamEmployees() {
    return _firestore.collection('students').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Student.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}
