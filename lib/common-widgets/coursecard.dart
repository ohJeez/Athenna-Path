import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  final String title;
  final String category;
  final String description;
  final String imageUrl;
  final String url;
  final VoidCallback onTap;

  const CourseCard({
    required this.title,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.url,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.only(right: 12, bottom: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: SizedBox(
          width: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        height: 90,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 90,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          );
                        },
                      )
                    : Container(
                        height: 90,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.isNotEmpty ? title : "No title available",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.isNotEmpty ? category : "Uncategorized",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
