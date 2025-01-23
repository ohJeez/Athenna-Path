import 'package:flutter/material.dart';
import '../models/employee_model.dart';
import '../services/employee_service.dart';
import '../common-widgets/appbar.dart';
import '../common-widgets/sidebar.dart';

class CompanyDashboard extends StatefulWidget {
  const CompanyDashboard({Key? key}) : super(key: key);

  @override
  _CompanyDashboardState createState() => _CompanyDashboardState();
}

class _CompanyDashboardState extends State<CompanyDashboard> {
  Map<String, List<Employee>> employeesByDepartment = {};
  bool isLoading = false;
  final EmployeeService _employeeService = EmployeeService();

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    setState(() => isLoading = true);
    try {
      final employees = await _employeeService.fetchEmployees();

      // Group employees by department
      final groupedEmployees = <String, List<Employee>>{};
      for (var employee in employees) {
        if (!groupedEmployees.containsKey(employee.department)) {
          groupedEmployees[employee.department] = [];
        }
        groupedEmployees[employee.department]!.add(employee);
      }

      setState(() {
        employeesByDepartment = groupedEmployees;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading employees: $e')),
      );
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuSidebar(),
      appBar: const AppBarWidget(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeText(),
                const SizedBox(height: 16.0),
                _buildCompanyStats(),
                const SizedBox(height: 20.0),
                _buildEmployeesSection(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add employee screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return const Text(
      "Company Dashboard",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 24.0,
      ),
    );
  }

  Widget _buildCompanyStats() {
    int totalEmployees = employeesByDepartment.values
        .fold(0, (sum, employees) => sum + employees.length);
    int totalDepartments = employeesByDepartment.length;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2E3F66),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Company Overview",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatsCard(
                icon: Icons.people_outline,
                label: "$totalEmployees Employees",
              ),
              _buildStatsCard(
                icon: Icons.business,
                label: "$totalDepartments Departments",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard({required IconData icon, required String label}) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: const Color(0xFF2E3F66)),
          const SizedBox(height: 8.0),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Employees by Department",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        const SizedBox(height: 16),
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : employeesByDepartment.isEmpty
                ? const Center(
                    child: Text(
                      "No employees found. Add your first employee!",
                      style: TextStyle(fontSize: 16.0),
                    ),
                  )
                : Column(
                    children: employeesByDepartment.entries.map((entry) {
                      return _buildDepartmentSection(entry.key, entry.value);
                    }).toList(),
                  ),
      ],
    );
  }

  Widget _buildDepartmentSection(String department, List<Employee> employees) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            department,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: employees.length,
          itemBuilder: (context, index) {
            return _buildEmployeeCard(employees[index]);
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEmployeeCard(Employee employee) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: employee.profilePicture.isNotEmpty
              ? NetworkImage(employee.profilePicture)
              : null,
          child: employee.profilePicture.isEmpty
              ? Text(employee.firstName[0] + employee.lastName[0])
              : null,
        ),
        title: Text('${employee.firstName} ${employee.lastName}'),
        subtitle: Text(employee.position),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navigate to employee details
        },
      ),
    );
  }
}
