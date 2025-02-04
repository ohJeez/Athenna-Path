class Job {
  final String id;
  final String title;
  final String description;
  final String location;
  final String company;
  final int company_id;
  final String salaryRange;
  final String requiredSkills;
  final String experienceLevel;
  final String qualification;
  final String deadline;
  final String employmentType;
  final String datePosted;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.company,
    required this.company_id,
    required this.salaryRange,
    required this.requiredSkills,
    required this.experienceLevel,
    required this.qualification,
    required this.deadline,
    required this.employmentType,
    required this.datePosted,
  });

  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      id: map['id'].toString(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      company: map['company'] ?? '',
      company_id: map['company_id'] ?? 0,
      salaryRange: map['salary_range']?.toString() ?? '',
      requiredSkills: map['required_skills'] ?? '',
      experienceLevel: map['experience_level'] ?? '',
      qualification: map['qualification'] ?? '',
      deadline: map['deadline'] ?? '',
      employmentType: map['employment_type'] ?? '',
      datePosted: map['date_posted'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'company': company,
      'company_id': company_id,
      'salary_range': salaryRange,
      'required_skills': requiredSkills,
      'experience_level': experienceLevel,
      'qualification': qualification,
      'deadline': deadline,
      'employment_type': employmentType,
      'date_posted': datePosted,
    };
  }
}

class JobProvider {
  final String jobProvider;
  final String url;

  JobProvider({
    required this.jobProvider,
    required this.url,
  });

  factory JobProvider.fromJson(Map<String, dynamic> json) {
    return JobProvider(
      jobProvider: json['jobProvider'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jobProvider': jobProvider,
      'url': url,
    };
  }
}
