class JobApplication {
  final String id;
  final String jobId;
  final String studentId;
  final String companyId;
  final String status;
  final DateTime appliedDate;
  final Map<String, dynamic>? studentDetails;

  JobApplication({
    required this.id,
    required this.jobId,
    required this.studentId,
    required this.companyId,
    required this.status,
    required this.appliedDate,
    this.studentDetails,
  });

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'studentId': studentId,
      'companyId': companyId,
      'status': status,
      'appliedDate': appliedDate.toIso8601String(),
      'studentDetails': studentDetails,
    };
  }

  factory JobApplication.fromMap(Map<String, dynamic> map, String id) {
    return JobApplication(
      id: id,
      jobId: map['jobId'] ?? '',
      studentId: map['studentId'] ?? '',
      companyId: map['companyId'] ?? '',
      status: map['status'] ?? 'pending',
      appliedDate: DateTime.parse(map['appliedDate']),
      studentDetails: map['studentDetails'],
    );
  }
}
