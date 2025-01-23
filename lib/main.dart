import 'package:final_project/screens/homepage.dart';
import 'package:final_project/screens/login/login.dart';
import 'package:final_project/screens/company_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:final_project/firebase/firebase_options.dart';
import 'services/company_service.dart';
import 'database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  // Initialize local database
  final dbHelper = DatabaseHelper();
  await dbHelper.database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  final CompanyService _companyService = CompanyService();

  AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          // Check if the logged-in user is a company
          return FutureBuilder<bool>(
            future: _companyService.isCompanyUser(snapshot.data!.uid),
            builder: (context, companySnapshot) {
              if (companySnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (companySnapshot.hasData && companySnapshot.data!) {
                // User is a company, get company data and show dashboard
                return FutureBuilder(
                  future: _companyService.getCompanyById(snapshot.data!.uid),
                  builder: (context, companyDataSnapshot) {
                    if (companyDataSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (companyDataSnapshot.hasData) {
                      return CompanyDashboard(
                          company: companyDataSnapshot.data!);
                    } else {
                      // Error loading company data
                      return const LoginPage();
                    }
                  },
                );
              } else {
                // User is not a company, show student homepage
                return homeStudent(user: snapshot.data!);
              }
            },
          );
        }

        // No user logged in, show login page
        return const LoginPage();
      },
    );
  }
}
