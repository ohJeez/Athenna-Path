import 'package:flutter/material.dart';
import 'package:final_project/common-functions/course-api.dart';
import 'package:final_project/models/course-models.dart';
import 'package:final_project/screens/searchResult.dart';

class CourseSearchDelegate extends SearchDelegate<String> {
  List<Course> recentSearches = [];
  List<Course> _suggestions = [];
  bool _isLoading = false;

  @override
  String get searchFieldLabel => 'Search for courses...';

  @override
  TextStyle get searchFieldStyle => const TextStyle(
    fontSize: 16.0,
    color: Colors.black87,
  );

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          if (query.isEmpty) {
            close(context, '');
          } else {
            query = '';
            showSuggestions(context);
          }
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return SearchResults(query: query);
  }

  Future<List<Course>> _getSuggestions(String query) async {
    if (query.isEmpty) return recentSearches;

    try {
      final results = await CourseAPI.searchCourses(query);
      return results.take(5).toList();
    } catch (e) {
      print('Error fetching suggestions: $e');
      return [];
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<Course>>(
      future: _getSuggestions(query),
      builder: (context, AsyncSnapshot<List<Course>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final suggestions = snapshot.data ?? [];

        if (suggestions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  query.isEmpty ? 'Start typing to search...' : 'No results found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          itemCount: suggestions.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final course = suggestions[index];
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  course.imageUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 40,
                      height: 40,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 20),
                    );
                  },
                ),
              ),
              title: Text(
                course.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
              subtitle: Text(
                course.category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              onTap: () {
                // Add to recent searches
                if (!recentSearches.contains(course)) {
                  recentSearches.insert(0, course);
                  if (recentSearches.length > 5) {
                    recentSearches.removeLast();
                  }
                }

                // Navigate to search results
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchResults(query: course.title),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}