import 'package:flutter/material.dart';
import '../models/job-models.dart';
import '../common-widgets/appbar.dart';

class JobDetailScreen extends StatelessWidget {
  final Job job;

  const JobDetailScreen({Key? key, required this.job}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Icon
            const Center(
              child: Icon(
                Icons.business,
                size: 100,
                color: Color(0xFF2E3F66),
              ),
            ),
            const SizedBox(height: 16),
            // Job Title
            Text(
              job.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3F66),
              ),
            ),
            const SizedBox(height: 8),
            // Company Name
            Text(
              job.company,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            // Location
            Row(
              children: [
                const Icon(Icons.location_on,
                    size: 16, color: Color(0xFF2E3F66)),
                const SizedBox(width: 4),
                Expanded(child: Text(job.location)),
              ],
            ),
            const SizedBox(height: 16),
            // Employment Type
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2E3F66).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                job.employmentType,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2E3F66),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Salary Range
            if (job.salaryRange.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildDetailRow('Salary Range', job.salaryRange),
            ],
            const SizedBox(height: 24),
            // Job Details Section
            const Text(
              'Job Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3F66),
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Description', job.description),
            _buildDetailRow('Required Skills', job.requiredSkills),
            _buildDetailRow('Experience Level', job.experienceLevel),
            _buildDetailRow('Qualification', job.qualification),
            _buildDetailRow('Application Deadline', job.deadline),
            _buildDetailRow('Posted On', job.datePosted),
            const SizedBox(height: 24),
            // Apply Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E3F66),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  // TODO: Implement application logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Application feature coming soon!')),
                  );
                },
                child: const Text(
                  'Apply Now',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3F66),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
