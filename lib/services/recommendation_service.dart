import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecommendationService {
  final String _baseUrl = 'http://localhost:5000/api';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get course recommendations based on user activity
  Future<List<Map<String, dynamic>>> getRecommendedCourses(String userId) async {
  try {
    // Get user's recent activities
    final recentSearches = await _getRecentSearches(userId);
    final recentViews = await _getRecentViews(userId);

    // Prepare user data for recommendation
    final userData = {
      'recent_searches': recentSearches,
      'recent_views': recentViews,
    };

    // Get recommendations from ML model
    final response = await http.post(
      Uri.parse('$_baseUrl/recommendations'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['recommendations'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  } catch (e) {
    print('Error getting recommendations: $e');
    return [];
  }
}

  // Track user search
  Future<void> logSearchQuery(String userId, String query) async {
    try {
      await _firestore.collection('user_searches').add({
        'userId': userId,
        'query': query,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error logging search: $e');
    }
  }

  // Track course views
  Future<void> logCourseView(String userId, String courseId) async {
    try {
      await _firestore.collection('user_course_views').add({
        'userId': userId,
        'courseId': courseId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error logging course view: $e');
    }
  }

  // Get recent searches
  Future<List<String>> _getRecentSearches(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('user_searches')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get();

      return snapshot.docs.map((doc) => doc['query'] as String).toList();
    } catch (e) {
      print('Error getting recent searches: $e');
      return [];
    }
  }

  // Get recent views
  Future<List<String>> _getRecentViews(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('user_course_views')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get();

      return snapshot.docs.map((doc) => doc['courseId'] as String).toList();
    } catch (e) {
      print('Error getting recent views: $e');
      return [];
    }
  }

  // API methods to interact with your Flask backend
  Future<List<Map<String, dynamic>>> searchCourses(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/courses/search/$query'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error searching courses: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getCourseById(int courseId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/courses/$courseId'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting course: $e');
      return null;
    }
  }
}
