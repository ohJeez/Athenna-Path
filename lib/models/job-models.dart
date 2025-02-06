import 'package:cloud_firestore/cloud_firestore.dart';

class Job {
  final String? id;
  final String title;
  final String company;
  final String companyId;
  final String description;
  final String location;
  final String salaryRange;
  final String requiredSkills;
  final String experienceLevel;
  final String qualification;
  final String deadline;
  final String employmentType;
  final String datePosted;
  final int applicationsCount;

  Job({
    this.id,
    required this.title,
    required this.company,
    required this.companyId,
    required this.description,
    required this.location,
    required this.salaryRange,
    required this.requiredSkills,
    required this.experienceLevel,
    required this.qualification,
    required this.deadline,
    required this.employmentType,
    required this.datePosted,
    this.applicationsCount = 0,  // Set default value
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'company': company,
      'companyId': companyId,
      'description': description,
      'location': location,
      'salary_range': salaryRange,
      'required_skills': requiredSkills,
      'experience_level': experienceLevel,
      'qualification': qualification,
      'deadline': deadline,
      'employment_type': employmentType,
      'date_posted': datePosted,
      'applications_count': applicationsCount,
    };
  }

  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      id: map['id'],
      title: map['title'] ?? '',
      company: map['company'] ?? '',
      companyId: map['companyId'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      salaryRange: map['salary_range']?.toString() ?? '',
      requiredSkills: map['required_skills'] ?? '',
      experienceLevel: map['experience_level'] ?? '',
      qualification: map['qualification'] ?? '',
      deadline: map['deadline'] ?? '',
      employmentType: map['employment_type'] ?? '',
      datePosted: map['date_posted'] ?? '',
      applicationsCount: map['applications_count'] ?? 0,
    );
  }

  // Add a copyWith method for updating jobs
  Job copyWith({
    String? id,
    String? title,
    String? company,
    String? companyId,
    String? description,
    String? location,
    String? salaryRange,
    String? requiredSkills,
    String? experienceLevel,
    String? qualification,
    String? deadline,
    String? employmentType,
    String? datePosted,
    int? applicationsCount,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      companyId: companyId ?? this.companyId,
      description: description ?? this.description,
      location: location ?? this.location,
      salaryRange: salaryRange ?? this.salaryRange,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      qualification: qualification ?? this.qualification,
      deadline: deadline ?? this.deadline,
      employmentType: employmentType ?? this.employmentType,
      datePosted: datePosted ?? this.datePosted,
      applicationsCount: applicationsCount ?? this.applicationsCount,
    );
  }
}