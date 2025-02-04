// import 'package:dio/dio.dart';
// import '../models/job-models.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';

// class JobAPI {
//   static const String _baseUrl = 'https://jsearch.p.rapidapi.com/search';
//   static const String _apiKey =
//       '31784a93dfmsh8449cc8f4d3dd25p18e51ajsnc4acf6cf5e5c';
//   static const String _apiHost = 'jsearch.p.rapidapi.com';
//   static final Dio _dio = Dio();

//   static Future<List<Job>> fetchJobs() async {
//     try {
//       // Try to check connectivity, but don't fail if plugin isn't available
//       try {
//         var connectivityResult = await Connectivity().checkConnectivity();
//         if (connectivityResult == ConnectivityResult.none) {
//           throw Exception(
//               'No internet connection. Please check your network settings.');
//         }
//       } catch (e) {
//         print('Connectivity check failed: $e');
//         // Continue anyway as the plugin might not be available
//       }

//       final response = await _dio.get(
//         _baseUrl,
//         queryParameters: {
//           'query': 'Web Developer',
//           'page': '1',
//           'num_pages': '1'
//         },
//         options: Options(
//           headers: {
//             'X-RapidAPI-Key': _apiKey,
//             'X-RapidAPI-Host': _apiHost,
//           },
//           sendTimeout: const Duration(seconds: 30),
//           receiveTimeout: const Duration(seconds: 30),
//         ),
//       );

//       if (response.statusCode == 200) {
//         // Debug print to verify response structure
//         print('API Response: ${response.data}');

//         final data = response.data;
//         if (data == null || data['data'] == null) {
//           throw Exception('Invalid response format from server');
//         }

//         final List<dynamic> jobs = data['data'];
//         return jobs
//             .map((job) {
//               try {
//                 // Debug print to verify individual job structure
//                 print('Processing job: ${job['job_title']}');
//                 print('Job structure: $job');

//                 return Job.fromJson({
//                   'id': job['job_id'] ?? '',
//                   'title': job['job_title'] ?? '',
//                   'company': job['employer_name'] ?? '',
//                   'description': job['job_description'] ?? '',
//                   'location': _formatLocation(job),
//                   'employmentType':
//                       job['job_employment_type']?.toString().toUpperCase() ??
//                           'Not specified',
//                   'image': job['employer_logo'] ?? '',
//                   'datePosted': job['job_posted_at_datetime_utc'] ?? '',
//                   'salaryRange': _formatSalaryRange(job),
//                   'jobProviders': [
//                     {
//                       'jobProvider': job['employer_name'] ?? '',
//                       'url': job['job_apply_link'] ?? '',
//                     }
//                   ],
//                 });
//               } catch (e) {
//                 print('Error parsing job: $e');
//                 return null;
//               }
//             })
//             .whereType<Job>()
//             .toList();
//       } else {
//         print('API Error Response: ${response.statusCode} - ${response.data}');
//         throw Exception('Failed to load jobs: ${response.statusCode}');
//       }
//     } on DioException catch (e) {
//       if (e.type == DioExceptionType.connectionTimeout ||
//           e.type == DioExceptionType.sendTimeout ||
//           e.type == DioExceptionType.receiveTimeout) {
//         throw Exception('Connection timed out. Please try again.');
//       } else if (e.type == DioExceptionType.connectionError) {
//         throw Exception(
//             'Connection error. Please check your internet connection.');
//       }
//       throw Exception('Failed to fetch jobs: ${e.message}');
//     } catch (e) {
//       print('Network Error: $e');
//       throw Exception('Error fetching jobs: $e');
//     }
//   }

//   static String _formatLocation(dynamic job) {
//     List<String> locationParts = [];
//     if (job['job_city'] != null && job['job_city'].toString().isNotEmpty) {
//       locationParts.add(job['job_city']);
//     }
//     if (job['job_state'] != null && job['job_state'].toString().isNotEmpty) {
//       locationParts.add(job['job_state']);
//     }
//     if (job['job_country'] != null &&
//         job['job_country'].toString().isNotEmpty) {
//       locationParts.add(job['job_country']);
//     }
//     return locationParts.isEmpty
//         ? 'Location not specified'
//         : locationParts.join(', ');
//   }

//   static String _formatSalaryRange(dynamic job) {
//     if (job['job_min_salary'] != null && job['job_max_salary'] != null) {
//       final minSalary = job['job_min_salary'].toString();
//       final maxSalary = job['job_max_salary'].toString();
//       final currency = job['job_salary_currency'] ?? 'USD';
//       return '$currency $minSalary-$maxSalary';
//     }
//     return 'Salary not specified';
//   }
// }
