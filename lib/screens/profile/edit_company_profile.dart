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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final updatedCompany = Company(
        id: widget.company.id,
        companyName: companyNameController.text,
        email: emailController.text,
        foundedYear: foundedYearController.text,
        companyType: companyTypeController.text,
        password: widget.company.password,
        createdAt: widget.company.createdAt,
      );

      await CompanyService().updateCompany(updatedCompany);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context, updatedCompany);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
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
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Company name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Email is required';
                  if (!value!.contains('@')) return 'Invalid email format';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: foundedYearController,
                decoration: const InputDecoration(
                  labelText: 'Founded Year',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Founded year is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: companyTypeController,
                decoration: const InputDecoration(
                  labelText: 'Company Type',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Company type is required' : null,
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
