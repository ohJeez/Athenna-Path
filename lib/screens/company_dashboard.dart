import 'package:flutter/material.dart';
import '../models/employee_model.dart';
import '../models/job_application.dart';
import '../models/student_models.dart';
import '../services/employee_service.dart';
import '../common-widgets/appbar.dart';
import '../common-widgets/sidebar.dart';
import '../models/company_model.dart';
import '../common-widgets/company_sidebar.dart';
import '../services/job_service.dart';
import '../models/job-models.dart';
import '../services/company_service.dart';
import '../services/firebase_service.dart';
import '../screens/jobs/create_job_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyDashboard extends StatefulWidget {
  final Company company;

  const CompanyDashboard({
    Key? key,
    required this.company,
  }) : super(key: key);

  @override
  _CompanyDashboardState createState() => _CompanyDashboardState();
}

class _CompanyDashboardState extends State<CompanyDashboard> {
  final EmployeeService _employeeService = EmployeeService();
  final JobService _jobService = JobService();
  List<Job> jobs = [];
  bool isLoading = true;
  Map<String, List<JobApplication>> _jobApplications = {};

  @override
  void initState() {
    super.initState();
    print('\n=== Company Dashboard Initialized ===');
    print('Company Name: ${widget.company.companyName}');
    print('Company ID: ${widget.company.id}');
    _loadJobs();
    _loadJobApplications();
    _setupApplicationListener();
  }

  Future<void> _loadJobs() async {
    if (!mounted) return;

    setState(() => isLoading = true);
    try {
      print('Loading jobs for company: ${widget.company.companyName}');
      final loadedJobs = await _jobService.getJobsByCompany(widget.company.id);

      if (!mounted) return;

      setState(() {
        jobs = loadedJobs;
        isLoading = false;
      });

      print('Loaded ${jobs.length} jobs');
    } catch (e) {
      print('Error loading jobs: $e');
      if (!mounted) return;

      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading jobs: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadJobApplications() async {
    if (!mounted) return;

    try {
      final applications =
          await _jobService.getApplicationsByCompany(widget.company.id);
      final companyJobs = await _jobService.getJobsByCompany(widget.company.id);

      if (!mounted) return;

      setState(() {
        _jobApplications = {};
        for (var job in companyJobs) {
          if (job.id != null) {
            _jobApplications[job.id!] =
                applications.where((app) => app.jobId == job.id).toList();
          }
        }
      });
    } catch (e) {
      print('Error loading applications: $e');
    }
  }

  Widget _buildEmployeeCard(Student employee) {
    // Create initials safely
    String getInitials() {
      String initials = '';
      if (employee.firstName.isNotEmpty) {
        initials += employee.firstName[0];
      }
      if (employee.lastName.isNotEmpty) {
        initials += employee.lastName[0];
      }
      return initials.isNotEmpty ? initials : '?';
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundImage: employee.profilePicture.isNotEmpty
              ? NetworkImage(employee.profilePicture)
              : null,
          child: employee.profilePicture.isEmpty
              ? Text(
                  getInitials(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )
              : null,
        ),
        title: Text(
          '${employee.firstName} ${employee.lastName}'.trim(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
            employee.email.isNotEmpty ? employee.email : 'No email provided'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (employee.phoneNumber.isNotEmpty)
                  _buildInfoRow('Phone', employee.phoneNumber),
                if (employee.gender.isNotEmpty)
                  _buildInfoRow('Gender', employee.gender),
                if (employee.dateOfBirth.isNotEmpty)
                  _buildInfoRow('Birth Date', employee.dateOfBirth),
                if (employee.description.isNotEmpty)
                  _buildInfoRow('Description', employee.description),
                if (employee.projects.isNotEmpty) ...[
                  const Divider(),
                  const Text(
                    'Projects',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  ...employee.projects.map((project) => ListTile(
                        title: Text(project.title.isNotEmpty
                            ? project.title
                            : 'Untitled Project'),
                        subtitle: Text(project.description.isNotEmpty
                            ? project.description
                            : 'No description available'),
                      )),
                ],
                if (employee.courses.isNotEmpty) ...[
                  const Divider(),
                  const Text(
                    'Courses',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  ...employee.courses.map((course) => ListTile(
                        title: Text(course.title.isNotEmpty
                            ? course.title
                            : 'Untitled Course'),
                        subtitle: Text(
                          [
                            if (course.instructor.isNotEmpty)
                              'Instructor: ${course.instructor}',
                            if (course.duration.isNotEmpty)
                              'Duration: ${course.duration}',
                            if (course.date.isNotEmpty) 'Date: ${course.date}',
                          ].join('\n'),
                        ),
                      )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showAddJobDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateJobPage(
          companyId: widget.company.id,
          companyName: widget.company.companyName,
        ),
      ),
    );
  }

  Widget _buildJobApplicationsSection(Job job) {
    final applications = _jobApplications[job.id] ?? [];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          job.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF2E3F66),
          ),
        ),
        subtitle: Text(
          '${applications.length} applications • ${job.employmentType}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job Details Section
                _buildJobDetailsSection(job),
                const Divider(height: 32),
                // Applications Section
                Text(
                  'Applications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                applications.isEmpty
                    ? const Center(
                        child: Text('No applications yet'),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: applications.length,
                        itemBuilder: (context, index) {
                          return _buildApplicationCard(applications[index]);
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobDetailsSection(Job job) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(Icons.location_on, job.location),
        _buildDetailRow(Icons.work, job.experienceLevel),
        _buildDetailRow(Icons.attach_money, job.salaryRange),
        _buildDetailRow(Icons.calendar_today, 'Posted: ${job.datePosted}'),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(JobApplication application) {
    return FutureBuilder<Student>(
      future: FirebaseService().getStudentProfile(application.studentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Loading...'),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.hasError) {
          return const Card(
            child: ListTile(
              title: Text('Error loading applicant data'),
              subtitle: Text('Please try again later'),
            ),
          );
        }

        final student = snapshot.data!;
        final applicationStatus = application.status.toLowerCase();

        // Safely create initials
        String initials = '';
        if (student.firstName.isNotEmpty) {
          initials += student.firstName[0];
        }
        if (student.lastName.isNotEmpty) {
          initials += student.lastName[0];
        }
        if (initials.isEmpty) {
          initials = '?';
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Text(
                initials,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            title: Text(
              '${student.firstName} ${student.lastName}'.trim(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (student.email.isNotEmpty) Text(student.email),
                Text(
                  'Applied: ${_formatDate(application.appliedDate)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              initialValue: applicationStatus,
              onSelected: (String status) async {
                try {
                  await _jobService.updateApplicationStatus(
                    application.id,
                    status,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Application status updated to $status'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _loadJobApplications(); // Reload applications after update
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error updating status: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(applicationStatus),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  applicationStatus.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'pending',
                  child: Text('Pending'),
                ),
                const PopupMenuItem<String>(
                  value: 'accepted',
                  child: Text('Accept'),
                ),
                const PopupMenuItem<String>(
                  value: 'rejected',
                  child: Text('Reject'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  // Add real-time listener for applications
  void _setupApplicationListener() {
    FirebaseFirestore.instance
        .collection('applications')
        .where('companyId', isEqualTo: widget.company.id)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        _loadJobApplications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Athenna Path',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                // Navigate to CompanyDashboard with current company data
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CompanyDashboard(
                      company: widget.company,
                    ),
                  ),
                );
              },
              child: const CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage('assets/images/logo.jpeg'),
              ),
            ),
          ),
        ],
      ),
      drawer: CompanySidebar(company: widget.company),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome section
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome,',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.grey[800],
                          ),
                        ),
                        Text(
                          widget.company.companyName,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E3F66),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Jobs section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Posted Jobs',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E3F66),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...jobs.map((job) => _buildJobApplicationsSection(job)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateJobPage(
                companyId: widget.company.id,
                companyName: widget.company.companyName,
              ),
            ),
          ).then((_) => _loadJobs());
        },
        backgroundColor: const Color(0xFF2E3F66),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Job',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up any subscriptions if needed
    super.dispose();
  }
}
