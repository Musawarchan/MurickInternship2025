enum CourseCategory { programming, design, business, marketing, other }

enum CourseDifficulty { beginner, intermediate, advanced }

class Course {
  final String id;
  final String title;
  final String subtitle;
  final String instructor;
  final String thumbnailUrl;
  final double rating;
  final int ratingCount;
  final bool isFree;
  final double price;
  final CourseCategory category;
  final CourseDifficulty difficulty;
  final String description;
  bool isEnrolled;

  Course({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.instructor,
    required this.thumbnailUrl,
    required this.rating,
    required this.ratingCount,
    required this.isFree,
    required this.price,
    required this.category,
    required this.difficulty,
    required this.description,
    this.isEnrolled = false,
  });
}
