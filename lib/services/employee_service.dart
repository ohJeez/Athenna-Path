import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/employee_model.dart';

class EmployeeService {
  final CollectionReference _employeeCollection =
      FirebaseFirestore.instance.collection('employees');

  Future<List<Employee>> fetchEmployees() async {
    try {
      final snapshot = await _employeeCollection.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Employee.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch employees: $e');
    }
  }

  Future<void> addEmployee(Employee employee) async {
    try {
      await _employeeCollection.add(employee.toJson());
    } catch (e) {
      throw Exception('Failed to add employee: $e');
    }
  }
}
