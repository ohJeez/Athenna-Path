class Employee {
  final int? emp_id;
  final String e_firstname;
  final String e_lastname;
  final String e_email;
  final int e_phone;
  final String e_position;
  final String e_department;
  final String e_joinDate;
  final String e_profilepicture;
  final int company_id;
  final String department;

  Employee({
    this.emp_id,
    required this.e_firstname,
    required this.e_lastname,
    required this.e_email,
    required this.e_phone,
    required this.e_position,
    required this.e_department,
    required this.e_joinDate,
    required this.e_profilepicture,
    required this.company_id,
    required this.department,
  });

  Map<String, dynamic> toJson() {
    return {
      if (emp_id != null) 'emp_id': emp_id,
      'e_firstname': e_firstname,
      'e_lastname': e_lastname,
      'e_email': e_email,
      'e_phone': e_phone,
      'e_position': e_position,
      'e_department': e_department,
      'e_joinDate': e_joinDate,
      'e_profilepicture': e_profilepicture,
      'company_id': company_id,
      'department': department,
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      emp_id: map['emp_id'] as int?,
      e_firstname: map['e_firstname'] as String,
      e_lastname: map['e_lastname'] as String,
      e_email: map['e_email'] as String,
      e_phone: map['e_phone'] as int,
      e_position: map['e_position'] as String,
      e_department: map['e_department'] as String,
      e_joinDate: map['e_joinDate'] as String,
      e_profilepicture: map['e_profilepicture'] as String,
      company_id: map['company_id'] as int,
      department: map['department'] as String,
    );
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      emp_id: json['emp_id'] as int?,
      e_firstname: json['e_firstname'] as String,
      e_lastname: json['e_lastname'] as String,
      e_email: json['e_email'] as String,
      e_phone: json['e_phone'] as int,
      e_position: json['e_position'] as String,
      e_department: json['e_department'] ?? '',
      e_joinDate: json['e_joinDate'] as String,
      e_profilepicture: json['e_profilepicture'] as String,
      company_id: json['company_id'] as int,
      department: json['department'] ?? '',
    );
  }
}

class Skill {
  final String name;
  final int level; // 1-5

  Skill({required this.name, required this.level});

  Map<String, dynamic> toJson() => {'name': name, 'level': level};

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      name: json['name'] ?? '',
      level: json['level'] ?? 1,
    );
  }
}
