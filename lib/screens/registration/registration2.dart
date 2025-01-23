import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/screens/login/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class registrationForm extends StatefulWidget {
  final String email;
  const registrationForm({super.key, required this.email});

  @override
  _registrationFormState createState() => _registrationFormState();
}

class _registrationFormState extends State<registrationForm> {
  String? selectedStream;
  String? selectedJobRole;
  String? selectedLevel;

  final List<String> streams = ["Computer Science"];
  final List<String> jobRoles = [
    "Software Developer",
    "Data Analyst",
    "System Administrator",
    "Not Decided Yet"
  ];
  final List<String> levels = [
    "Higher Secondary",
    "Undergraduation",
    "Post Graduation",
    "Diploma",
    "Doctorate"
  ];

  final _formKey = GlobalKey<FormState>();

  Future<void> updateStudentData() async {
    try {
      // Get current user
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      await FirebaseFirestore.instance
          .collection('students')
          .doc(currentUser.uid) // Use the UID directly
          .update({
        'stream': selectedStream,
        'jobRole': selectedJobRole,
        'level': selectedLevel,
      });

      print('Profile updated successfully');
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/images/logo.jpeg',
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    buildDropdownField(
                      label: 'Stream',
                      hint: 'Enter your preferred Stream',
                      items: streams,
                      value: selectedStream,
                      onChanged: (value) =>
                          setState(() => selectedStream = value),
                    ),
                    const SizedBox(height: 20),
                    buildDropdownField(
                      label: 'Job Role',
                      hint: 'Enter your preferred Job Role',
                      items: jobRoles,
                      value: selectedJobRole,
                      onChanged: (value) =>
                          setState(() => selectedJobRole = value),
                    ),
                    const SizedBox(height: 20),
                    buildDropdownField(
                      label: 'Currently Undergoing',
                      hint: 'Enter your current level undergoing',
                      items: levels,
                      value: selectedLevel,
                      onChanged: (value) =>
                          setState(() => selectedLevel = value),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (selectedStream != null &&
                              selectedJobRole != null &&
                              selectedLevel != null) {
                            await updateStudentData();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ),
                            );
                            // Navigate to next page
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select all fields!'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.all(20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDropdownField({
    required String label,
    required String hint,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label*',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white60),
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          dropdownColor: Colors.black,
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
          validator: (value) => value == null || value.isEmpty
              ? 'Please select a valid $label'
              : null,
        ),
      ],
    );
  }
}
