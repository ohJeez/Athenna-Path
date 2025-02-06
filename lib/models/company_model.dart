import 'package:cloud_firestore/cloud_firestore.dart';

class Company {
  final String id;
  final String companyName;
  final String email;
  final String foundedYear;
  final String companyType;
  final String? adminName;
  final DateTime? createdAt;

  Company({
    required this.id,
    required this.companyName,
    required this.email,
    required this.foundedYear,
    required this.companyType,
    this.adminName,
    this.createdAt,
  });

  factory Company.fromFirestore(Map<String, dynamic> data) {
    return Company(
      id: data['id'] ?? '',
      companyName: data['companyName'] ?? '',
      email: data['email'] ?? '',
      foundedYear: data['foundedYear'] ?? '',
      companyType: data['companyType'] ?? '',
      adminName: data['adminName'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'companyName': companyName,
      'email': email,
      'foundedYear': foundedYear,
      'companyType': companyType,
      'adminName': adminName,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }

  // Convert Company instance to Map for database operations
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'email': email,
      'foundedYear': foundedYear,
      'adminName': adminName,
      'companyType': companyType,
    };
  }

  // Create a safe version of Company without sensitive data
  Company toSafeCompany() {
    return Company(
      id: id,
      companyName: companyName,
      email: email,
      foundedYear: foundedYear,
      companyType: companyType,
      adminName: adminName,
      createdAt: createdAt,
    );
  }

  // Create Company instance from Map
  factory Company.fromMap(Map<String, dynamic> map) {
    return Company(
      id: map['id'] as String,
      companyName: map['companyName'] as String,
      email: map['email'] as String,
      foundedYear: map['foundedYear'] as String,
      companyType: map['companyType'] as String,
      adminName: map['adminName'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Copy with method to create a new instance with some updated fields
  Company copyWith({
    String? id,
    String? companyName,
    String? email,
    String? foundedYear,
    String? adminName,
    String? companyType,
    DateTime? createdAt,
  }) {
    return Company(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      email: email ?? this.email,
      foundedYear: foundedYear ?? this.foundedYear,
      adminName: adminName ?? this.adminName,
      companyType: companyType ?? this.companyType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Company{id: $id, companyName: $companyName, email: $email, companyType: $companyType}';
  }

  // Add this method for creating company from auth
  static Company createFromAuth(String uid, Map<String, String> data) {
    return Company(
      id: uid,
      companyName: data['companyName'] ?? '',
      email: data['email'] ?? '',
      foundedYear: data['foundedYear'] ?? '',
      companyType: data['companyType'] ?? '',
      createdAt: DateTime.now(),
    );
  }
}
