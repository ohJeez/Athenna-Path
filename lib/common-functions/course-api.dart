import 'package:dio/dio.dart';
import '../models/course-models.dart';

class CourseAPI {
  static const String baseUrl =
      'http://10.0.2.2:8000'; // Android emulator localhost
  static final Dio _dio = Dio();

  /// Fetches a list of courses.
  static Future<List<Course>> fetchCourses() async {
    try {
      final response = await _dio.get('$baseUrl/courses');

      print('API Response Status: ${response.statusCode}');
      print('API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> coursesData = response.data;
        return coursesData
            .map((courseData) => Course.fromJson(courseData))
            .toList();
      } else {
        throw Exception('Failed to load courses: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching courses: $e');
      throw Exception('Failed to fetch courses: $e');
    }
  }

  /// Searches for courses based on a query string.
  static Future<List<Course>> searchCourses(String query) async {
    try {
      final response =
          await _dio.get('$baseUrl/courses/search', queryParameters: {
        'query': query,
        'limit': 10,
      });

      print('Raw API Response: ${response.data}'); // Debug print

      if (response.statusCode == 200) {
        final List<dynamic> coursesData = response.data;
        return coursesData
            .map((courseData) => Course.fromJson(courseData))
            .toList();
      } else {
        throw Exception('Failed to search courses: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching courses: $e');
      throw Exception('Error searching courses: $e');
    }
  }
}
