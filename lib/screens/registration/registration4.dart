import 'package:final_project/screens/login/login2.dart';
import 'package:final_project/screens/registration/registration5.dart';
import 'package:flutter/material.dart';
import '../../firebase/company_service.dart';

class CompanyRegistrationPage extends StatefulWidget {
  const CompanyRegistrationPage({super.key});

  @override
  State<CompanyRegistrationPage> createState() =>
      _CompanyRegistrationPageState();
}

class _CompanyRegistrationPageState extends State<CompanyRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _foundedYearController = TextEditingController();
  final TextEditingController _adminNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _companyTypeController = TextEditingController();
  final CompanyService _companyService = CompanyService();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  void _registerCompany() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // Navigate to password page and pass the company data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PasswordRegistrationPage(
              companyData: {
                'companyName': _companyNameController.text,
                'foundedYear': _foundedYearController.text,
                'adminName': _adminNameController.text,
                'email': _emailController.text,
                'companyType': _companyTypeController.text,
              },
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Logo
                ClipOval(
                  child: Image.asset(
                    'assets/images/logo.jpeg',
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Register Your Company 👋",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Fill in the details below to create your company account",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(height: 30),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Company Name Field
                      TextFormField(
                        controller: _companyNameController,
                        decoration: _buildInputDecoration(
                          "Company Name",
                          "Enter your company name",
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) => value == null || value.isEmpty
                            ? "Please enter your company name"
                            : null,
                      ),
                      const SizedBox(height: 20),
                      // Founded Year Field
                      TextFormField(
                        controller: _foundedYearController,
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration(
                          "Founded Year",
                          "Enter the year your company was founded",
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) => value == null || value.isEmpty
                            ? "Please enter the year your company was founded"
                            : null,
                      ),
                      const SizedBox(height: 20),
                      // Admin Name Field
                      TextFormField(
                        controller: _adminNameController,
                        decoration: _buildInputDecoration(
                          "Admin Name",
                          "Enter the administrator's name",
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) => value == null || value.isEmpty
                            ? "Please enter the administrator's name"
                            : null,
                      ),
                      const SizedBox(height: 20),
                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _buildInputDecoration(
                          "Email Address",
                          "Enter the company's email address",
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your email address";
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return "Please enter a valid email";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Company Type Field
                      TextFormField(
                        controller: _companyTypeController,
                        decoration: _buildInputDecoration(
                          "Company Type",
                          "Enter the type of your company (e.g., IT, Manufacturing, etc.)",
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) => value == null || value.isEmpty
                            ? "Please enter the type of your company"
                            : null,
                      ),
                      const SizedBox(height: 30),
                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _registerCompany,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Register Company",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already registered?",
                            style: TextStyle(color: Colors.white54),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CompanyLoginPage(),
                                  ));
                            },
                            child: const Text(
                              "Sign In",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Colors.white),
      hintStyle: const TextStyle(color: Colors.white60),
      filled: true,
      fillColor: Colors.white10,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}
