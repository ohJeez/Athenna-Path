import 'package:flutter/material.dart';

import '../models/student_models.dart';

class CVPreview extends StatelessWidget {
  final Student student;

  const CVPreview({Key? key, required this.student}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CV Preview'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${student.firstName} ${student.lastName}', style: const TextStyle(fontSize: 18)),
            Text('Phone: ${student.phoneNumber}', style: const TextStyle(fontSize: 18)),
            Text('Gender: ${student.gender}', style: const TextStyle(fontSize: 18)),
            Text('DOB: ${student.dateOfBirth}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            const Text('Description:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(student.description),
            const SizedBox(height: 16),
            const Text('Projects:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...student.projects.map((project) => Text('- ${project.title}: ${project.description}')).toList(),
            const SizedBox(height: 16),
            const Text('Courses:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...student.courses.map((course) => Text('- ${course.title} by ${course.instructor} on ${course.date} (${course.duration})')).toList(),
          ],
        ),
      ),
    );
  }
}
