import 'package:flutter/material.dart';
import '../models/employee_model.dart';
import '../models/student_models.dart';
import '../services/employee_service.dart';
import '../common-widgets/appbar.dart';
import '../common-widgets/sidebar.dart';
import '../models/company_model.dart';
import '../common-widgets/company_sidebar.dart';

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
    );
  }
}
