import 'package:flutter/material.dart';
import '../../models/job-models.dart';
import '../../services/job_service.dart';

class EditJobPage extends StatefulWidget {
  final Job job;

  const EditJobPage({Key? key, required this.job}) : super(key: key);

  @override
  State<EditJobPage> createState() => _EditJobPageState();
}

class _EditJobPageState extends State<EditJobPage> {
  final _formKey = GlobalKey<FormState>();
  final JobService _jobService = JobService();
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController locationController;
  late TextEditingController salaryRangeController;
  late TextEditingController requiredSkillsController;
  late TextEditingController experienceLevelController;
  late TextEditingController qualificationController;
  late TextEditingController deadlineController;
  late TextEditingController employmentTypeController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.job.title);
    descriptionController = TextEditingController(text: widget.job.description);
    locationController = TextEditingController(text: widget.job.location);
    salaryRangeController = TextEditingController(text: widget.job.salaryRange);
    requiredSkillsController =
        TextEditingController(text: widget.job.requiredSkills);
    experienceLevelController =
        TextEditingController(text: widget.job.experienceLevel);
    qualificationController =
        TextEditingController(text: widget.job.qualification);
    deadlineController = TextEditingController(text: widget.job.deadline);
    employmentTypeController =
        TextEditingController(text: widget.job.employmentType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Job'),
        backgroundColor: const Color(0xFF2E3F66),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Job Title'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: salaryRangeController,
                decoration: const InputDecoration(labelText: 'Salary Range'),
              ),
              TextFormField(
                controller: requiredSkillsController,
                decoration: const InputDecoration(labelText: 'Required Skills'),
              ),
              TextFormField(
                controller: experienceLevelController,
                decoration:
                    const InputDecoration(labelText: 'Experience Level'),
              ),
              TextFormField(
                controller: qualificationController,
                decoration: const InputDecoration(labelText: 'Qualification'),
              ),
              TextFormField(
                controller: deadlineController,
                decoration: const InputDecoration(labelText: 'Deadline'),
              ),
              TextFormField(
                controller: employmentTypeController,
                decoration: const InputDecoration(labelText: 'Employment Type'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E3F66),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    final updatedJob = Job(
                      id: widget.job.id,
                      title: titleController.text,
                      description: descriptionController.text,
                      location: locationController.text,
                      company: widget.job.company,
                      company_id: widget.job.company_id,
                      salaryRange: salaryRangeController.text,
                      requiredSkills: requiredSkillsController.text,
                      experienceLevel: experienceLevelController.text,
                      qualification: qualificationController.text,
                      deadline: deadlineController.text,
                      employmentType: employmentTypeController.text,
                      datePosted: widget.job.datePosted,
                    );

                    try {
                      await _jobService.updateJob(updatedJob);
                      if (mounted) {
                        Navigator.pop(context, updatedJob);
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error updating job: $e')),
                        );
                      }
                    }
                  }
                },
                child: const Text('Update Job',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    salaryRangeController.dispose();
    requiredSkillsController.dispose();
    experienceLevelController.dispose();
    qualificationController.dispose();
    deadlineController.dispose();
    employmentTypeController.dispose();
    super.dispose();
  }
}
