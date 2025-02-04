import 'package:flutter/material.dart';
import '../../models/company_model.dart';
import '../../models/job-models.dart';
import '../../services/job_service.dart';
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
  final JobService _jobService = JobService();
  late Company company;
  List<Job> jobs = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    company = widget.company;
    fetchJobs();
  }

  Future<void> fetchJobs() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final loadedJobs = await _jobService.getJobs();
      if (mounted) {
        setState(() {
          jobs =
              loadedJobs.where((job) => job.company_id == company.id).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching jobs: $e');
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load jobs: ${e.toString()}';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteJob(String jobId) async {
    try {
      await _jobService.deleteJob(jobId);
      await fetchJobs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting job: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CompanySidebar(company: company),
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
                        onPressed: fetchJobs,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchJobs,
                  child: SingleChildScrollView(
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
                                children: jobs
                                    .map((job) => _buildJobCard(job))
                                    .toList(),
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
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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

  Widget _buildJobCard(Job job) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(job.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(job.location ?? 'Location not specified'),
            Text(job.employmentType ?? 'Employment type not specified',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                    TextButton(
                      onPressed: () => _editJob(job),
                      child: const Text('Edit'),
                    ),
                    TextButton(
                      onPressed: () => _showDeleteConfirmation(job),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
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
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value.isNotEmpty ? value : 'Not specified'),
          ),
        ],
      ),
    );
  }

  void _editJob(Job job) async {
    // Navigate to job editing screen and wait for result
    final updatedJob = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditJobPage(job: job),
      ),
    );

    // If job was updated, refresh the jobs list
    if (updatedJob != null) {
      await fetchJobs();
    }
  }

  void _showDeleteConfirmation(Job job) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content:
              const Text('Are you sure you want to delete this job posting?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteJob(job.id);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
