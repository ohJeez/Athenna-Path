import 'package:flutter/material.dart';
import '../models/job-models.dart';
import '../common-widgets/appbar.dart';
import '../common-widgets/sidebar.dart';
import '../services/job_service.dart';
import 'jobDetail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobListing extends StatefulWidget {
  const JobListing({Key? key}) : super(key: key);

  @override
  _JobListingState createState() => _JobListingState();
}

class _JobListingState extends State<JobListing> {
  final JobService _jobService = JobService();
  List<Job> jobs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('jobs').get();
      setState(() {
        jobs = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return Job.fromMap(data);
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading jobs: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(),
      drawer: const MenuSidebar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final job = jobs[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      job.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(job.company),
                        const SizedBox(height: 4),
                        Text(job.location),
                        const SizedBox(height: 8),
                        Text(
                          job.salaryRange,
                          style: const TextStyle(
                            color: Color(0xFF2E3F66),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JobDetailScreen(job: job),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
