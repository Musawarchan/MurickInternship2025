import 'lesson.dart';
import 'review.dart';

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
  final List<Lesson> lessons;
  final int totalDuration; // Total duration in seconds
  final int lessonCount;
  final List<Review> reviews;

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
    this.lessons = const [],
    this.totalDuration = 0,
    this.lessonCount = 0,
    this.reviews = const [],
  });

  String get formattedTotalDuration {
    final hours = totalDuration ~/ 3600;
    final minutes = (totalDuration % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  Course copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? instructor,
    String? thumbnailUrl,
    double? rating,
    int? ratingCount,
    bool? isFree,
    double? price,
    CourseCategory? category,
    CourseDifficulty? difficulty,
    String? description,
    bool? isEnrolled,
    List<Lesson>? lessons,
    int? totalDuration,
    int? lessonCount,
    List<Review>? reviews,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      instructor: instructor ?? this.instructor,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      isFree: isFree ?? this.isFree,
      price: price ?? this.price,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      description: description ?? this.description,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      lessons: lessons ?? this.lessons,
      totalDuration: totalDuration ?? this.totalDuration,
      lessonCount: lessonCount ?? this.lessonCount,
      reviews: reviews ?? this.reviews,
    );
  }
}
