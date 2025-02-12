class Course {
  final String? id;
  final String title;
  final String category;
  final String description;
  final String imageUrl;
  final String url;
  final double duration;

  Course({
    this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.url,
    required this.duration,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    try {
      return Course(
        id: json['course_id'].toString(),
        title: json['course_title'] ?? 'No Title',
        category: json['subject'] ?? 'No Category',
        description: '''
Level: ${json['level'] ?? 'Not specified'}
Duration: ${json['content_duration']} hours
Lectures: ${json['num_lectures']}
Reviews: ${json['num_reviews']}
Price: \$${json['price']}
''',
        imageUrl:
            'https://img-c.udemycdn.com/course/${json['course_id']}_480x270.jpg',
        url: json['url'] ?? '',
        duration: (json['content_duration'] ?? 0).toDouble(),
      );
    } catch (e) {
      print('Error parsing course: $e');
      print('JSON data: $json');
      return Course(
        id: null,
        title: 'Error Loading Course',
        category: 'Unknown',
        description: 'Failed to load course details',
        imageUrl: 'https://via.placeholder.com/150',
        url: '',
        duration: 0,
      );
    }
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'],
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      url: map['url'] ?? '',
      duration: (map['duration'] ?? 0).toDouble(),
    );
  }
}

// Extension to safely parse string to int
extension StringExtension on String {
  int? tryParse() {
    try {
      return int.parse(this);
    } catch (e) {
      return null;
    }
  }
}
