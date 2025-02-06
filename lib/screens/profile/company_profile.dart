import 'package:flutter/material.dart';
import '../../models/company_model.dart';
import '../../models/job-models.dart';
import '../../services/company_service.dart';
import '../../common-widgets/appbar.dart';
import '../../common-widgets/company_sidebar.dart';
import 'edit_company_profile.dart';
import '../jobs/edit_job_page.dart';

class CompanyProfile extends StatefulWidget {
  final Company company;

  const CompanyProfile({Key? key, required this.company}) : super(key: key);

  @override
  State<CompanyProfile> createState() => _CompanyProfileState();
}

class _CompanyProfileState extends State<CompanyProfile> {
  final CompanyService _companyService = CompanyService();
  late Company company;
  Stream<List<Job>>? _jobsStream;

  @override
  void initState() {
    super.initState();
    company = widget.company;
    _jobsStream = _companyService.streamCompanyJobs(company.id);
  }

  Future<void> _deleteJob(String jobId) async {
    try {
      await _companyService.deleteJob(jobId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting job: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(Job job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Job'),
        content: Text('Are you sure you want to delete "${job.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (job.id != null) {
                _deleteJob(job.id!);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error: Job ID is missing'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _editJob(Job job) async {
    final updatedJob = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditJobPage(job: job),
      ),
    );

    if (updatedJob != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildJobCard(Job job) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: ExpansionTile(
        title: Text(
          job.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E3F66),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job.location ?? 'Location not specified',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              job.employmentType ?? 'Employment type not specified',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildJobDetail(
                    'Description', job.description ?? 'No description'),
                _buildJobDetail('Salary Range',
                    job.salaryRange?.toString() ?? 'Not specified'),
                _buildJobDetail(
                    'Required Skills', job.requiredSkills ?? 'Not specified'),
                _buildJobDetail(
                    'Experience Level', job.experienceLevel ?? 'Not specified'),
                _buildJobDetail(
                    'Qualification', job.qualification ?? 'Not specified'),
                _buildJobDetail('Deadline', job.deadline ?? 'Not specified'),
                _buildJobDetail('Posted On', job.datePosted ?? 'Not specified'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _editJob(job),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF2E3F66),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _showDeleteConfirmation(job),
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('Delete'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3F66),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CompanySidebar(company: company),
      appBar: const AppBarWidget(),
      body: StreamBuilder<List<Job>>(
        stream: _jobsStream,
        builder: (context, AsyncSnapshot<List<Job>> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _jobsStream =
                            _companyService.streamCompanyJobs(company.id);
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final jobs = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    child: Text(
                      company.companyName[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E3F66),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildProfileItem('Company Name', company.companyName),
                _buildProfileItem('Email', company.email),
                _buildProfileItem('Founded Year', company.foundedYear),
                _buildProfileItem('Company Type', company.companyType),
                const SizedBox(height: 20),
                const Text(
                  'Posted Job Roles',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3F66),
                  ),
                ),
                const SizedBox(height: 10),
                jobs.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            'No job roles posted yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        children:
                            jobs.map((job) => _buildJobCard(job)).toList(),
                      ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E3F66),
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 40,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      final updatedCompany = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditCompanyProfile(
                            company: company,
                          ),
                        ),
                      );

                      if (updatedCompany != null) {
                        setState(() {
                          company = updatedCompany;
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
          );
        },
      ),
    );
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
}
