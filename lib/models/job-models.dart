class Job {
  final String id;
  final String title;
  final String company;
  final String description;
  final String location;
  final String employmentType;
  final List<JobProvider> jobProviders;
  final String image;
  final String datePosted;
  final String salaryRange;

  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.description,
    required this.location,
    required this.employmentType,
    required this.jobProviders,
    this.image = '',
    this.datePosted = '',
    this.salaryRange = 'Not specified',
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    List<JobProvider> providers = [];
    if (json['jobProviders'] != null) {
      providers = (json['jobProviders'] as List)
          .map((provider) => JobProvider.fromJson(provider))
          .toList();
    }

    return Job(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      employmentType: json['employmentType'] ?? '',
      image: json['image'] ?? '',
      datePosted: json['datePosted'] ?? '',
      salaryRange: json['salaryRange'] ?? 'Not specified',
      jobProviders: providers,
    );
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
}
