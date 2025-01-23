import 'package:final_project/common-functions/course-api.dart';
import 'package:final_project/common-widgets/coursecard.dart';
import 'package:final_project/models/course-models.dart';
import 'package:flutter/material.dart';
import 'package:final_project/screens/courseDetailPage.dart';

class SearchResults extends StatefulWidget {
  final String query;

  const SearchResults({Key? key, required this.query}) : super(key: key);

  @override
  _SearchResultsState createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  List<Course> searchResults = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    searchCourses(widget.query);
  }

  Future<void> searchCourses(String query) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      print('Searching for courses with query: $query');
      final results = await CourseAPI.searchCourses(query);
      print('Found ${results.length} results');

      if (mounted) {
        setState(() {
          searchResults = results;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error searching courses: $e');
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load search results';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage,
                        style: const TextStyle(fontSize: 18.0),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => searchCourses(widget.query),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : searchResults.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "No results found",
                            style: TextStyle(fontSize: 18.0),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try searching for something else',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final course = searchResults[index];
                        return CourseCard(
                          title: course.title,
                          category: course.category,
                          description: course.description,
                          imageUrl: course.imageUrl,
                          url: course.url,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CourseDetailScreen(course: course),
                              ),
                            );
                          },
                        );
                      },
                    ),
    );
  }
}
