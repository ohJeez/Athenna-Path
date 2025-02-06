import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job-models.dart';
import '../models/job_application.dart';

class JobService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create new job
  Future<void> createJob(Job job) async {
    try {
      await _firestore.collection('jobs').add({
        'title': job.title,
        'company': job.company,
        'companyId': job.companyId,
        'description': job.description,
        'location': job.location,
        'salary_range': job.salaryRange,
        'required_skills': job.requiredSkills,
        'experience_level': job.experienceLevel,
        'qualification': job.qualification,
        'deadline': job.deadline,
        'employment_type': job.employmentType,
        'date_posted': DateTime.now().toIso8601String(),
        'applications_count': 0,
      });
    } catch (e) {
      throw Exception('Failed to create job: $e');
    }
  }

  // Get jobs by company
  Future<List<Job>> getJobsByCompany(String companyId) async {
    try {
      final snapshot = await _firestore
          .collection('jobs')
          .where('companyId', isEqualTo: companyId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Job.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch company jobs: $e');
    }
  }

  // Handle job application
  Future<void> applyForJob(
      String jobId, String studentId, String companyId) async {
    try {
      await _firestore.collection('applications').add({
        'jobId': jobId,
        'studentId': studentId,
        'companyId': companyId,
        'status': 'pending',
        'appliedDate': DateTime.now().toIso8601String(),
      });

      // Update applications count
      await _firestore.collection('jobs').doc(jobId).update({
        'applications_count': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to apply for job: $e');
    }
  }

  // Get all jobs for student view
  Stream<List<Job>> getAllJobs() {
    return _firestore
        .collection('jobs')
        .orderBy('datePosted', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Job.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Get applications for a job
  Stream<List<JobApplication>> getJobApplications(String jobId) {
    return _firestore
        .collection('applications')
        .where('jobId', isEqualTo: jobId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => JobApplication.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Update application status
  Future<void> updateApplicationStatus(
      String applicationId, String status) async {
    await _firestore.collection('applications').doc(applicationId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Add this method to get applications by company
  Future<List<JobApplication>> getApplicationsByCompany(
      String companyId) async {
    try {
      final snapshot = await _firestore
          .collection('applications')
          .where('companyId', isEqualTo: companyId)
          .get();

      return snapshot.docs.map((doc) {
        return JobApplication.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Error getting applications: $e');
      throw Exception('Failed to load applications: $e');
    }
  }

  // Add this method to get applications by job
  Future<List<JobApplication>> getApplicationsByJob(String jobId) async {
    try {
      final snapshot = await _firestore
          .collection('applications')
          .where('jobId', isEqualTo: jobId)
          .get();

      return snapshot.docs.map((doc) {
        return JobApplication.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Error getting applications for job: $e');
      throw Exception('Failed to load job applications: $e');
    }
  }

  // Add this method to check if a student has already applied
  Future<bool> hasStudentApplied(String jobId, String studentId) async {
    try {
      final snapshot = await _firestore
          .collection('applications')
          .where('jobId', isEqualTo: jobId)
          .where('studentId', isEqualTo: studentId)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking application status: $e');
      throw Exception('Failed to check application status: $e');
    }
  }

  // Add this method to get application statistics
  Future<Map<String, int>> getApplicationStatistics(String companyId) async {
    try {
      final applications = await getApplicationsByCompany(companyId);

      return {
        'total': applications.length,
        'pending': applications.where((app) => app.status == 'pending').length,
        'accepted':
            applications.where((app) => app.status == 'accepted').length,
        'rejected':
            applications.where((app) => app.status == 'rejected').length,
      };
    } catch (e) {
      print('Error getting application statistics: $e');
      throw Exception('Failed to load application statistics: $e');
    }
  }

  // Add updateJob method
  Future<void> updateJob(Job job) async {
    try {
      await _firestore.collection('jobs').doc(job.id).update({
        'title': job.title,
        'description': job.description,
        'location': job.location,
        'salary_range': job.salaryRange,
        'required_skills': job.requiredSkills,
        'experience_level': job.experienceLevel,
        'qualification': job.qualification,
        'deadline': job.deadline,
        'employment_type': job.employmentType,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating job: $e');
      throw Exception('Failed to update job: $e');
    }
  }
}
