class Employee {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String position;
  final String department;
  final String joinDate;
  final String profilePicture;
  final List<Skill> skills;

  Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.position,
    required this.department,
    required this.joinDate,
    this.profilePicture = '',
    this.skills = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'position': position,
      'department': department,
      'joinDate': joinDate,
      'profilePicture': profilePicture,
      'skills': skills.map((skill) => skill.toJson()).toList(),
    };
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      position: json['position'] ?? '',
      department: json['department'] ?? '',
      joinDate: json['joinDate'] ?? '',
      profilePicture: json['profilePicture'] ?? '',
      skills: (json['skills'] as List<dynamic>?)
              ?.map((skill) => Skill.fromJson(skill))
              .toList() ??
          [],
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
