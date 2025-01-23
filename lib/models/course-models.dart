class Course {
  final String title;
  final String category;
  final String description;
  final String imageUrl;
  final String url;
  final int duration;

  Course({
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
        title: json['name']?.toString() ?? 'No Title',
        category: json['category']?.toString() ?? 'No Category',
        description: json['description']?.toString() ?? 'No Description',
        imageUrl: json['image']?.toString() ??
            'https://via.placeholder.com/150',
        url: json['url']?.toString() ?? '',
        duration: (json['content_info_short']?.toString() ?? '0 hours')
                .split(' ')
                .first
                .tryParse() ??
            0,
      );
    } catch (e) {
      print('Error parsing course: $e');
      print('JSON data: $json');
      return Course(
        title: 'Error Loading Course',
        category: 'Unknown',
        description: 'Failed to load course details',
        imageUrl: 'https://via.placeholder.com/150',
        url: '',
        duration: 0,
      );
    }
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
