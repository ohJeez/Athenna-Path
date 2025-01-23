import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_models.dart';

class FirestoreService {
  final CollectionReference _studentCollection =
  FirebaseFirestore.instance.collection('students');

  // Add a Student to Firestore
  Future<void> addStudent(Student student) async {
    try {
      await _studentCollection.add({
        'firstName': student.firstName,
        'lastName': student.lastName,
        'phoneNumber': student.phoneNumber,
        'dateOfBirth': student.dateOfBirth,
        'description': student.description,
        'gender': student.gender,
        'profilePicture': student.profilePicture,
        'projects': student.projects
            .map((project) => {
          'title': project.title,
          'description': project.description,
        })
            .toList(),
        'courses': student.courses
            .map((course) => {
          'title': course.title,
          'instructor': course.instructor,
          'date': course.date,
          'duration': course.duration,
        })
            .toList(),
      });
    } catch (e) {
      throw Exception('Failed to add student: $e');
    }
  }

  // Fetch Students from Firestore
  Future<List<Student>> fetchStudents() async {
    try {
      final snapshot = await _studentCollection.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Student(
          firstName: data['firstName'] ?? '',
          lastName: data['lastName'] ?? '',
          phoneNumber: data['phoneNumber'] ?? '',
          dateOfBirth: data['dateOfBirth'] ?? '',
          description: data['description'] ?? '',
          gender: data['gender'] ?? '',
          profilePicture: data['profilePicture'] ?? '',
          projects: (data['projects'] as List)
              ?.map((project) => Project(
            title: project['title'],
            description: project['description'],
          ))
              ?.toList() ??
              [],
          courses: (data['courses'] as List)
              ?.map((course) => Course(
            title: course['title'],
            instructor: course['instructor'],
            date: course['date'],
            duration: course['duration'],
          ))
              ?.toList() ??
              [],
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch students: $e');
    }
  }
}
