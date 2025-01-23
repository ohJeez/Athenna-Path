import 'dart:io';
import 'package:final_project/common-widgets/appbar.dart';
import 'package:final_project/common-widgets/sidebar.dart';
import 'package:final_project/screens/profile/editProfilescreen.dart';
import 'package:flutter/material.dart';
import '../../models/student_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firebase_service.dart';

class UserProfile extends StatefulWidget {
  final Student student;

  const UserProfile({Key? key, required this.student}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final FirebaseService _firebaseService = FirebaseService();
  late Student student;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    student = widget.student;
    fetchStudentData();
  }

  Future<void> fetchStudentData() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser == null) {
      setState(() {
        errorMessage = 'No user logged in';
        isLoading = false;
      });
      return;
    }

    try {
      final updatedStudent = await _firebaseService.getStudentProfile(currentUser.uid);
      
      if (mounted) {
        setState(() {
          student = updatedStudent;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching student data: $e');
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load profile data';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuSidebar(),
      appBar: const AppBarWidget(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchStudentData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchStudentData,
                  child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundImage: student.profilePicture.isNotEmpty
                    ? FileImage(File(student.profilePicture))
                    : const AssetImage('assets/images/userprofile') as ImageProvider,
                child: student.profilePicture.isEmpty
                    ? const Icon(Icons.person, size: 40, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 10.0),
            _buildProfileItem('First Name', student.firstName),
            _buildProfileItem('Last Name', student.lastName),
            _buildProfileItem('Phone Number', student.phoneNumber),
            _buildProfileItem('Gender', student.gender),
            _buildProfileItem('Date of Birth', student.dateOfBirth),
            _buildProfileItem('Description', student.description),
            const SizedBox(height: 20.0),
            const Text(
              'Projects',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ...student.projects.map((project) => _buildProjectItem(project)),
            const SizedBox(height: 20.0),
            const Text(
              'Courses Completed',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ...student.courses.map((course) => _buildCourseItem(course)),
            const SizedBox(height: 30.0),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  final updatedStudent = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfile(student: student),
                    ),
                  );

                  // Update the state with the modified student data
                  if (updatedStudent != null) {
                    setState(() {
                      student = updatedStudent;
                    });
                  }
                },
                child: const Text(
                  'Update Profile',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildProfileItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Not Provided',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectItem(Project project) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(project.title, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(project.description),
      ),
    );
  }

  Widget _buildCourseItem(Course course) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(course.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${course.instructor} • ${course.date} • ${course.duration}'),
      ),
    );
  }
}
