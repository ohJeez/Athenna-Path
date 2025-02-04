class Company {
  final int? id;
  final String companyName;
  final String foundedYear;
  final String email;
  final String companyType;
  final String password;
  final String createdAt;

  Company({
    this.id,
    required this.companyName,
    required this.foundedYear,
    required this.email,
    required this.companyType,
    required this.password,
    required this.createdAt,
  });

  // Convert Company instance to Map for database operations
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'companyName': companyName,
      'foundedYear': foundedYear,
      'email': email.toLowerCase(),
      'companyType': companyType,
      'password': password,
      'createdAt': createdAt,
    };
  }

  // Create a safe version of Company without sensitive data
  Company toSafeCompany() {
    return Company(
      id: id,
      companyName: companyName,
      foundedYear: foundedYear,
      email: email,
      companyType: companyType,
      password: '', // Remove sensitive data
      createdAt: createdAt,
    );
  }

  // Create Company instance from Map
  factory Company.fromMap(Map<String, dynamic> map) {
    return Company(
      id: map['id'] as int?,
      companyName: map['companyName'] as String,
      foundedYear: map['foundedYear'] as String,
      email: map['email'] as String,
      companyType: map['companyType'] as String,
      password: map['password'] as String,
      createdAt: map['createdAt'] as String,
    );
  }

  // Copy with method to create a new instance with some updated fields
  Company copyWith({
    int? id,
    String? companyName,
    String? foundedYear,
    String? email,
    String? companyType,
    String? password,
    String? createdAt,
  }) {
    return Company(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      foundedYear: foundedYear ?? this.foundedYear,
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
