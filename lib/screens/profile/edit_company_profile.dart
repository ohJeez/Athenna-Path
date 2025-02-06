import 'package:flutter/material.dart';
import '../../models/company_model.dart';
import '../../services/company_service.dart';

class EditCompanyProfile extends StatefulWidget {
  final Company company;

  const EditCompanyProfile({Key? key, required this.company}) : super(key: key);

  @override
  State<EditCompanyProfile> createState() => _EditCompanyProfileState();
}

class _EditCompanyProfileState extends State<EditCompanyProfile> {
  final _formKey = GlobalKey<FormState>();
  final _companyService = CompanyService();
  bool _isSaving = false;
  late TextEditingController companyNameController;
  late TextEditingController emailController;
  late TextEditingController foundedYearController;
  late TextEditingController companyTypeController;

  @override
  void initState() {
    super.initState();
    companyNameController =
        TextEditingController(text: widget.company.companyName);
    emailController = TextEditingController(text: widget.company.email);
    foundedYearController =
        TextEditingController(text: widget.company.foundedYear);
    companyTypeController =
        TextEditingController(text: widget.company.companyType);
  }

  @override
  void dispose() {
    companyNameController.dispose();
    emailController.dispose();
    foundedYearController.dispose();
    companyTypeController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validateFoundedYear(String? value) {
    if (value == null || value.isEmpty) {
      return 'Founded year is required';
    }
    final year = int.tryParse(value);
    if (year == null) {
      return 'Please enter a valid year';
    }
    final currentYear = DateTime.now().year;
    if (year < 1800 || year > currentYear) {
      return 'Please enter a valid year between 1800 and $currentYear';
    }
    return null;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final newEmail = emailController.text.trim();
      final currentEmail = widget.company.email;

      // Check if email is being changed
      if (newEmail != currentEmail) {
        // Check if new email exists
        final emailExists = await _companyService.checkEmailExists(newEmail);
        if (emailExists) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This email is already registered'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isSaving = false);
          return;
        }
      }

      // Create updated company object
      final updatedCompany = Company(
        id: widget.company.id,
        companyName: companyNameController.text.trim(),
        email: newEmail,
        foundedYear: foundedYearController.text.trim(),
        companyType: companyTypeController.text.trim(),
      );

      // Update company profile
      await _companyService.updateCompany(updatedCompany);

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Return to previous screen with updated company data
      Navigator.pop(context, updatedCompany);
    } catch (e) {
      if (!mounted) return;

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Company Profile'),
        backgroundColor: const Color(0xFF2E3F66),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: companyNameController,
                decoration: const InputDecoration(
                  labelText: 'Company Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.trim().isEmpty == true
                    ? 'Company name is required'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: _validateEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: foundedYearController,
                decoration: const InputDecoration(
                  labelText: 'Founded Year',
                  border: OutlineInputBorder(),
                ),
                validator: _validateFoundedYear,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: companyTypeController,
                decoration: const InputDecoration(
                  labelText: 'Company Type',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.trim().isEmpty == true
                    ? 'Company type is required'
                    : null,
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E3F66),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isSaving ? null : _saveProfile,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
