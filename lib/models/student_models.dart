import 'dart:io';

class Student {
  String firstName;
  String lastName;
  String email;
  String phoneNumber;
  String dateOfBirth;
  String description;
  String gender;
  String profilePicture; // Path to profile picture
  List<Project> projects;
  List<Course> courses;

  Student({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phoneNumber = '',
    this.dateOfBirth = '',
    this.description = '',
    this.gender = '',
    this.profilePicture = '', // Default is empty
    this.projects = const [],
    this.courses = const [],
  });

  // Add these methods to convert to/from JSON
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth,
      'description': description,
      'gender': gender,
      'profilePicture': profilePicture,
      'projects': projects.map((project) => project.toJson()).toList(),
      'courses': courses.map((course) => course.toJson()).toList(),
    };
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      description: json['description'] ?? '',
      gender: json['gender'] ?? '',
      profilePicture: json['profilePicture'] ?? '',
      projects: (json['projects'] as List<dynamic>?)
              ?.map((project) => Project.fromJson(project))
              .toList() ??
          [],
      courses: (json['courses'] as List<dynamic>?)
              ?.map((course) => Course.fromJson(course))
              .toList() ??
          [],
    );
  }
}

class Project {
  String title;
  String description;

  Project({required this.title, required this.description});

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class Course {
  String title;
  String instructor;
  String date;
  String duration;

  Course({
    required this.title,
    required this.instructor,
    required this.date,
    required this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'instructor': instructor,
      'date': date,
      'duration': duration,
    };
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      title: json['title'] ?? '',
      instructor: json['instructor'] ?? '',
      date: json['date'] ?? '',
      duration: json['duration'] ?? '',
    );
  }
}
