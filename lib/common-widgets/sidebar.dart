import 'package:final_project/screens/chat_assistant.dart';
import 'package:final_project/screens/jobListing.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:final_project/models/student_models.dart';
import 'package:final_project/screens/homepage.dart';
import 'package:final_project/screens/profile/studentProfile.dart';
import 'package:final_project/screens/login/login.dart';
import 'package:final_project/screens/mockTest.dart';
import 'package:final_project/services/firebase_service.dart';
import 'dart:io';

class MenuSidebar extends StatefulWidget {
  const MenuSidebar({Key? key}) : super(key: key);

  @override
  State<MenuSidebar> createState() => _MenuSidebarState();
}

class _MenuSidebarState extends State<MenuSidebar> {
  final FirebaseService _firebaseService = FirebaseService();
  bool isLoading = false;
  String error = '';

  Future<void> _navigateToProfile(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first')),
      );
      return;
    }

    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final student = await _firebaseService.getStudentProfile(user.uid);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfile(student: student),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'Failed to load profile';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: FutureBuilder<Student>(
              future: user != null
                  ? _firebaseService.getStudentProfile(user.uid)
                  : null,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                      '${snapshot.data!.firstName} ${snapshot.data!.lastName}');
                }
                return Text(user?.displayName ?? 'Guest User');
              },
            ),
            accountEmail: Text(user?.email ?? 'guest@example.com'),
            currentAccountPicture: FutureBuilder<Student>(
              future: user != null
                  ? _firebaseService.getStudentProfile(user.uid)
                  : null,
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    snapshot.data!.profilePicture.isNotEmpty) {
                  return CircleAvatar(
                    backgroundImage:
                        FileImage(File(snapshot.data!.profilePicture)),
                  );
                }
                return const CircleAvatar(
                  backgroundImage: AssetImage('assets/images/profile_pic.png'),
                );
              },
            ),
            decoration: const BoxDecoration(color: Color(0xFF2E3F66)),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Color(0xFF2E3F66)),
            title: const Text("Home"),
            onTap: () {
              if (user != null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => homeStudent(user: user),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFF2E3F66)),
            title: const Text("Profile"),
            onTap: isLoading ? null : () => _navigateToProfile(context),
          ),
          ListTile(
            leading: const Icon(Icons.quiz, color: Color(0xFF2E3F66)),
            title: const Text("Mock Test"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MockTest()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.work, color: Color(0xFF2E3F66)),
            title: const Text("Chat Assistant"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatAssistant()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.work, color: Color(0xFF2E3F66)),
            title: const Text("Jobs"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const JobListing()),
              );
            },
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                error,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFF2E3F66)),
            title: const Text("Log Out"),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
