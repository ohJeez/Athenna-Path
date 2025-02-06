import 'package:flutter/material.dart';
import '../../models/job-models.dart';
import '../../services/job_service.dart';

class CreateJobPage extends StatefulWidget {
  final String companyId;
  final String companyName;

  const CreateJobPage(
      {Key? key, required this.companyId, required this.companyName})
      : super(key: key);

  @override
  State<CreateJobPage> createState() => _CreateJobPageState();
}

class _CreateJobPageState extends State<CreateJobPage> {
  final _formKey = GlobalKey<FormState>();
  final _jobService = JobService();
  bool _isLoading = false;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryRangeController = TextEditingController();
  final _requiredSkillsController = TextEditingController();
  final _experienceLevelController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _deadlineController = TextEditingController();
  String _selectedEmploymentType = 'Full-time';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _salaryRangeController.dispose();
    _requiredSkillsController.dispose();
    _experienceLevelController.dispose();
    _qualificationController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  Future<void> _createJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final job = Job(
        title: _titleController.text,
        company: widget.companyName,
        companyId: widget.companyId,
        description: _descriptionController.text,
        location: _locationController.text,
        salaryRange: _salaryRangeController.text,
        requiredSkills: _requiredSkillsController.text,
        experienceLevel: _experienceLevelController.text,
        qualification: _qualificationController.text,
        deadline: _deadlineController.text,
        employmentType: _selectedEmploymentType,
        datePosted: DateTime.now().toIso8601String(),
        applicationsCount: 0,
      );

      await _jobService.createJob(job);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job created successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating job: $e')),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Job'),
        backgroundColor: const Color(0xFF2E3F66),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Job Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a job title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Job Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) => value?.isEmpty ?? true
                    ? 'Please enter a description'
                    : null,
              ),
              const SizedBox(height: 16),
              // Add more form fields...
              ElevatedButton(
                onPressed: _isLoading ? null : _createJob,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E3F66),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Create Job'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
