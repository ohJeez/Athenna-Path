import 'package:flutter/material.dart';
import '../models/job-models.dart';
import '../common-widgets/appbar.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
            if (job.image.isNotEmpty)
              Center(
                child: CachedNetworkImage(
                  imageUrl: job.image,
                  height: 100,
                  fit: BoxFit.contain,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.business,
                    size: 100,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              job.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              job.company,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 4),
                Expanded(child: Text(job.location)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Employment Type: ${job.employmentType}',
              style: const TextStyle(fontSize: 16),
            ),
            if (job.salaryRange != 'Not specified') ...[
              const SizedBox(height: 8),
              Text(
                'Salary Range: ${job.salaryRange}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Description:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(job.description),
            if (job.jobProviders.isNotEmpty) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Add URL launcher functionality
                },
                child: const Text('Apply Now'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
