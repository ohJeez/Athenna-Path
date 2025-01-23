class Company {
  final String id;
  final String companyName;
  final String foundedYear;
  final String adminName;
  final String email;
  final String companyType;
  final String password;
  final String createdAt;

  Company({
    required this.id,
    required this.companyName,
    required this.foundedYear,
    required this.adminName,
    required this.email,
    required this.companyType,
    required this.password,
    required this.createdAt,
  });

  factory Company.fromMap(Map<String, dynamic> map) {
    return Company(
      id: map['id'] ?? '',
      companyName: map['companyName'] ?? '',
      foundedYear: map['foundedYear'] ?? '',
      adminName: map['adminName'] ?? '',
      email: map['email'] ?? '',
      companyType: map['companyType'] ?? '',
      password: map['password'] ?? '',
      createdAt: map['createdAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'companyName': companyName,
      'foundedYear': foundedYear,
      'adminName': adminName,
      'email': email,
      'companyType': companyType,
      'password': password,
      'createdAt': createdAt,
    };
  }

  // Add method to create a safe version of the company without sensitive data
  Company toSafeCompany() {
    return Company(
      id: id,
      companyName: companyName,
      foundedYear: foundedYear,
      adminName: adminName,
      email: email,
      companyType: companyType,
      password: '', // Remove password for security
      createdAt: createdAt,
    );
  }

  // Add method to copy company with modifications
  Company copyWith({
    String? id,
    String? companyName,
    String? foundedYear,
    String? adminName,
    String? email,
    String? companyType,
    String? password,
    String? createdAt,
  }) {
    return Company(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      foundedYear: foundedYear ?? this.foundedYear,
      adminName: adminName ?? this.adminName,
      email: email ?? this.email,
      companyType: companyType ?? this.companyType,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    // Don't include password in toString for security
    return 'Company{id: $id, companyName: $companyName, email: $email, companyType: $companyType}';
  }
}
