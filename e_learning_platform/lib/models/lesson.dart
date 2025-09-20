import 'package:hive/hive.dart';

part 'lesson.g.dart';

@HiveType(typeId: 1)
enum LessonType {
  @HiveField(0)
  video,
  @HiveField(1)
  pdf,
  @HiveField(2)
  text,
  @HiveField(3)
  quiz,
}

@HiveType(typeId: 2)
class Lesson extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String courseId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final LessonType type;

  @HiveField(5)
  final String contentUrl; // Video URL, PDF URL, or text content

  @HiveField(6)
  final int duration; // Duration in seconds

  @HiveField(7)
  final int order; // Order in the course

  @HiveField(8)
  final bool isPreview; // Can be viewed without enrollment

  @HiveField(9)
  final List<String> resources; // Additional resources like PDFs

  Lesson({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.type,
    required this.contentUrl,
    required this.duration,
    required this.order,
    this.isPreview = false,
    this.resources = const [],
  });

  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  Lesson copyWith({
    String? id,
    String? courseId,
    String? title,
    String? description,
    LessonType? type,
    String? contentUrl,
    int? duration,
    int? order,
    bool? isPreview,
    List<String>? resources,
  }) {
    return Lesson(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      contentUrl: contentUrl ?? this.contentUrl,
      duration: duration ?? this.duration,
      order: order ?? this.order,
      isPreview: isPreview ?? this.isPreview,
      resources: resources ?? this.resources,
    );
  }
}

@HiveType(typeId: 3)
class LessonProgress extends HiveObject {
  @HiveField(0)
  final String lessonId;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final double progress; // 0.0 to 1.0

  @HiveField(3)
  final bool isCompleted;

  @HiveField(4)
  final DateTime lastWatched;

  @HiveField(5)
  final int watchTime; // Time watched in seconds

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime updatedAt;

  LessonProgress({
    required this.lessonId,
    required this.userId,
    required this.progress,
    required this.isCompleted,
    required this.lastWatched,
    required this.watchTime,
    required this.createdAt,
    required this.updatedAt,
  });

  LessonProgress copyWith({
    String? lessonId,
    String? userId,
    double? progress,
    bool? isCompleted,
    DateTime? lastWatched,
    int? watchTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LessonProgress(
      lessonId: lessonId ?? this.lessonId,
      userId: userId ?? this.userId,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      lastWatched: lastWatched ?? this.lastWatched,
      watchTime: watchTime ?? this.watchTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@HiveType(typeId: 4)
class CourseProgress extends HiveObject {
  @HiveField(0)
  final String courseId;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final double overallProgress; // 0.0 to 1.0

  @HiveField(3)
  final int completedLessons;

  @HiveField(4)
  final int totalLessons;

  @HiveField(5)
  final DateTime lastAccessed;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime updatedAt;

  CourseProgress({
    required this.courseId,
    required this.userId,
    required this.overallProgress,
    required this.completedLessons,
    required this.totalLessons,
    required this.lastAccessed,
    required this.createdAt,
    required this.updatedAt,
  });

  CourseProgress copyWith({
    String? courseId,
    String? userId,
    double? overallProgress,
    int? completedLessons,
    int? totalLessons,
    DateTime? lastAccessed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CourseProgress(
      courseId: courseId ?? this.courseId,
      userId: userId ?? this.userId,
      overallProgress: overallProgress ?? this.overallProgress,
      completedLessons: completedLessons ?? this.completedLessons,
      totalLessons: totalLessons ?? this.totalLessons,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
