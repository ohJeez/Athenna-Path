import 'package:dio/dio.dart';
import 'package:final_project/models/course-models.dart';

class CourseAPI {
  static const String baseUrl =
      'https://udemy-paid-courses-for-free-api.p.rapidapi.com/rapidapi/courses/search';
  static const String apiKey =
      '43a4911da6msh017344646daf56bp1f509cjsnad615a48eae9';

  static final Dio _dio = Dio();

  /// Fetches a list of courses.
  static Future<List<Course>> fetchCourses(
      {int page = 1, int pageSize = 20}) async {
    try {
      final response = await _dio.get(
        baseUrl,
        queryParameters: {
          'page': page.toString(),
          'page_size': pageSize.toString(),
          'query': 'programming',
          'language': 'English',
          'price': 'price-free',
        },
        options: Options(
          headers: {
            'X-RapidAPI-Key': apiKey,
            'X-RapidAPI-Host': 'udemy-paid-courses-for-free-api.p.rapidapi.com',
          },
        ),
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> coursesData = response.data['courses'] ?? [];
        print('Number of courses fetched: ${coursesData.length}');

        if (coursesData.isNotEmpty) {
          print('Sample course data: ${coursesData[0]}');
        }

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
  static Future<List<Course>> searchCourses(String query,
      {int page = 1, int pageSize = 20}) async {
    try {
      final response = await _dio.get(
        baseUrl,
        queryParameters: {
          'page': page.toString(),
          'page_size': pageSize.toString(),
          'query': query,
          'language': 'English',
          'price': 'price-free',
        },
        options: Options(
          headers: {
            'X-RapidAPI-Key': apiKey,
            'X-RapidAPI-Host': 'udemy-paid-courses-for-free-api.p.rapidapi.com',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> coursesData = response.data['courses'] ?? [];
        return coursesData
            .map((courseData) => Course.fromJson(courseData))
            .toList();
      } else {
        throw Exception('Failed to search courses: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching courses: $e');
    }
  }
}
