import 'package:final_project/common-functions/course-api.dart';
import 'package:final_project/common-widgets/appbar.dart';
import 'package:final_project/common-widgets/coursecard.dart';
import 'package:final_project/common-widgets/sidebar.dart';
import 'package:final_project/models/course-models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:final_project/screens/courseDetailPage.dart';

class homeStudent extends StatefulWidget {
  final User user;

  const homeStudent({Key? key, required this.user}) : super(key: key);

  @override
  _homeStudentState createState() => _homeStudentState();
}

class _homeStudentState extends State<homeStudent> {
  Map<String, List<Course>> coursesByCategory = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    setState(() => isLoading = true);
    try {
      print('Fetching courses...');
      final fetchedCourses = await CourseAPI.fetchCourses();
      print('Fetched ${fetchedCourses.length} courses');

      // Group courses by category
      final groupedCourses = <String, List<Course>>{};
      for (var course in fetchedCourses) {
        if (!groupedCourses.containsKey(course.category)) {
          groupedCourses[course.category] = [];
        }
        groupedCourses[course.category]!.add(course);
      }

      if (mounted) {
        setState(() {
          coursesByCategory = groupedCourses;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching courses: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading courses: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuSidebar(),
      appBar: AppBarWidget(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeText(),
                const SizedBox(height: 16.0),
                _buildProgressStats(),
                const SizedBox(height: 20.0),
                _buildCoursesSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Text(
      "Welcome, ${widget.user.displayName ?? 'Student'}",
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 24.0,
      ),
    );
  }

  Widget _buildProgressStats() {
    int totalCourses = coursesByCategory.values
        .fold<int>(0, (sum, courses) => sum + courses.length);
    double totalHours = coursesByCategory.values.fold<double>(
        0,
        (sum, courses) =>
            sum +
            courses.fold<double>(0, (sum, course) => sum + course.duration));
    int totalModules = totalCourses * 5;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2E3F66),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Learning Progress",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatsCard(
                  icon: Icons.menu_book_outlined,
                  label: "$totalCourses courses"),
              _buildStatsCard(
                  icon: Icons.access_time,
                  label: "${totalHours.toInt()} hours"),
              _buildStatsCard(
                  icon: Icons.grid_on_outlined, label: "$totalModules modules"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard({required IconData icon, required String label}) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: const Color(0xFF2E3F66)),
          const SizedBox(height: 8.0),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Available Courses",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
          ),
        ),
        const SizedBox(height: 16),
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : coursesByCategory.isEmpty
                ? const Center(
                    child: Text(
                      "No courses available. Start learning today!",
                      style: TextStyle(fontSize: 16.0),
                    ),
                  )
                : Column(
                    children: coursesByCategory.entries.map((entry) {
                      return _buildCategorySection(entry.key, entry.value);
                    }).toList(),
                  ),
      ],
    );
  }

  Widget _buildCategorySection(String category, List<Course> courses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to category-specific course list
                },
                child: const Text(
                  "See All",
                  style: TextStyle(color: Color(0xFF2E3F66)),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: courses.length,
            itemBuilder: (context, index) {
              return SizedBox(
                width: 220,
                child: _buildCourseCard(courses[index]),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildCourseCard(Course course) {
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
            builder: (context) => CourseDetailScreen(course: course),
          ),
        );
      },
    );
  }
}
