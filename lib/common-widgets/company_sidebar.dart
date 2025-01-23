import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/company_dashboard.dart';
import '../screens/login/login2.dart';
import '../models/company_model.dart';

class CompanySidebar extends StatefulWidget {
  final Company company;

  const CompanySidebar({
    Key? key,
    required this.company,
  }) : super(key: key);

  @override
  State<CompanySidebar> createState() => _CompanySidebarState();
}

class _CompanySidebarState extends State<CompanySidebar> {
  bool isLoading = false;
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              widget.company.companyName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(widget.company.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                widget.company.companyName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E3F66),
                ),
              ),
            ),
            decoration: const BoxDecoration(color: Color(0xFF2E3F66)),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard, color: Color(0xFF2E3F66)),
            title: const Text("Dashboard"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CompanyDashboard(company: widget.company),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.business, color: Color(0xFF2E3F66)),
            title: const Text("Company Profile"),
            onTap: () {
              // TODO: Navigate to company profile page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Company Profile - Coming Soon'),
                  duration: Duration(seconds: 2),
                ),
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
              try {
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CompanyLoginPage()),
                    (route) => false,
                  );
                }
              } catch (e) {
                setState(() {
                  error = 'Failed to log out';
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $error')),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
