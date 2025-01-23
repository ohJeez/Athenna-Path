import 'package:flutter/material.dart';
import '../models/employee_model.dart';
import '../models/student_models.dart';
import '../services/employee_service.dart';
import '../common-widgets/appbar.dart';
import '../common-widgets/sidebar.dart';
import '../models/company_model.dart';
import '../common-widgets/company_sidebar.dart';
import '../services/job_service.dart';
import '../models/job-models.dart';

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
  List<Student> employees = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    print('\n=== Company Dashboard Initialized ===');
    print('Company Name: ${widget.company.companyName}');
    print('Company ID: ${widget.company.id}');
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    if (!mounted) return;

    setState(() => isLoading = true);
    try {
      print('Loading employees for company: ${widget.company.companyName}');
      final loadedEmployees = await _employeeService.getEmployees();

      if (!mounted) return;

      setState(() {
        employees = loadedEmployees;
        isLoading = false;
      });

      print('Loaded ${employees.length} employees');
    } catch (e) {
      print('Error loading employees: $e');
      if (!mounted) return;

      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading employees: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
    final _formKey = GlobalKey<FormState>();
    String title = '';
    String description = '';
    String location = '';
    String employmentType = '';
    String salaryRange = '';
    String requiredSkills = '';
    String experienceLevel = '';
    String qualification = '';
    String deadline = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Add New Job Role',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E3F66),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Job Title*',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required field' : null,
                      onSaved: (value) => title = value ?? '',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Description*',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required field' : null,
                      onSaved: (value) => description = value ?? '',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Location*',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required field' : null,
                      onSaved: (value) => location = value ?? '',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Employment Type*',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required field' : null,
                      onSaved: (value) => employmentType = value ?? '',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Salary Range',
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (value) => salaryRange = value ?? '',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Required Skills*',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required field' : null,
                      onSaved: (value) => requiredSkills = value ?? '',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Experience Level*',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required field' : null,
                      onSaved: (value) => experienceLevel = value ?? '',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Qualification*',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required field' : null,
                      onSaved: (value) => qualification = value ?? '',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Application Deadline*',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required field' : null,
                      onSaved: (value) => deadline = value ?? '',
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E3F66),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          _formKey.currentState?.save();

                          final job = Job(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            title: title,
                            company: widget.company.companyName,
                            description: description,
                            location: location,
                            employmentType: employmentType,
                            jobProviders: [],
                            datePosted: DateTime.now().toString(),
                            salaryRange: salaryRange,
                            requiredSkills: requiredSkills,
                            experienceLevel: experienceLevel,
                            qualification: qualification,
                            deadline: deadline,
                          );

                          try {
                            await JobService().addJob(job);
                            if (mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Job added successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error adding job: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                      child: const Text(
                        'Add Job',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
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
      body: RefreshIndicator(
        onRefresh: _loadEmployees,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Welcome Message
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome,',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.company.companyName,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E3F66),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Employees to Hire Title
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    width: double.infinity,
                    child: const Text(
                      'Employees to Hire',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E3F66),
                      ),
                    ),
                  ),
                  // Employee List
                  Expanded(
                    child: employees.isEmpty
                        ? const Center(
                            child: Text('No students found'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            itemCount: employees.length,
                            itemBuilder: (context, index) =>
                                _buildEmployeeCard(employees[index]),
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddJobDialog,
        backgroundColor: const Color(0xFF2E3F66),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Job Role',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
