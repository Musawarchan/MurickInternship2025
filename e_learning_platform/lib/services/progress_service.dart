import 'package:hive_flutter/hive_flutter.dart';
import '../models/lesson.dart';

class ProgressService {
  static const String _lessonProgressBoxName = 'lesson_progress';
  static const String _courseProgressBoxName = 'course_progress';
  static const String _notesBoxName = 'lesson_notes';

  static late Box<LessonProgress> _lessonProgressBox;
  static late Box<CourseProgress> _courseProgressBox;
  static late Box<String> _notesBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(LessonProgressAdapter());
    Hive.registerAdapter(CourseProgressAdapter());

    // Open boxes
    _lessonProgressBox =
        await Hive.openBox<LessonProgress>(_lessonProgressBoxName);
    _courseProgressBox =
        await Hive.openBox<CourseProgress>(_courseProgressBoxName);
    _notesBox = await Hive.openBox<String>(_notesBoxName);
  }

  // Lesson Progress Methods
  static Future<void> updateLessonProgress({
    required String lessonId,
    required String userId,
    required double progress,
    required int watchTime,
  }) async {
    final key = '${userId}_$lessonId';
    final now = DateTime.now();

    final existingProgress = _lessonProgressBox.get(key);

    if (existingProgress != null) {
      final updatedProgress = existingProgress.copyWith(
        progress: progress,
        watchTime: watchTime,
        isCompleted: progress >= 0.9, // Auto-complete at 90%
        lastWatched: now,
        updatedAt: now,
      );
      await _lessonProgressBox.put(key, updatedProgress);
    } else {
      final newProgress = LessonProgress(
        lessonId: lessonId,
        userId: userId,
        progress: progress,
        isCompleted: progress >= 0.9,
        lastWatched: now,
        watchTime: watchTime,
        createdAt: now,
        updatedAt: now,
      );
      await _lessonProgressBox.put(key, newProgress);
    }

    // Update course progress
    await _updateCourseProgress(userId, lessonId);
  }

  static LessonProgress? getLessonProgress(String lessonId, String userId) {
    final key = '${userId}_$lessonId';
    return _lessonProgressBox.get(key);
  }

  static List<LessonProgress> getCourseLessonProgress(
      String courseId, String userId) {
    return _lessonProgressBox.values
        .where((progress) =>
            progress.userId == userId && progress.lessonId.startsWith(courseId))
        .toList();
  }

  static Future<void> markLessonCompleted(
      String lessonId, String userId) async {
    final key = '${userId}_$lessonId';
    final now = DateTime.now();

    final existingProgress = _lessonProgressBox.get(key);

    if (existingProgress != null) {
      final updatedProgress = existingProgress.copyWith(
        progress: 1.0,
        isCompleted: true,
        lastWatched: now,
        updatedAt: now,
      );
      await _lessonProgressBox.put(key, updatedProgress);
    } else {
      final newProgress = LessonProgress(
        lessonId: lessonId,
        userId: userId,
        progress: 1.0,
        isCompleted: true,
        lastWatched: now,
        watchTime: 0,
        createdAt: now,
        updatedAt: now,
      );
      await _lessonProgressBox.put(key, newProgress);
    }

    await _updateCourseProgress(userId, lessonId);
  }

  // Course Progress Methods
  static Future<void> _updateCourseProgress(
      String userId, String lessonId) async {
    final courseId = lessonId
        .split('_')
        .first; // Assuming lessonId format: courseId_lessonNumber
    final key = '${userId}_$courseId';
    final now = DateTime.now();

    final lessonProgresses = getCourseLessonProgress(courseId, userId);
    final completedLessons =
        lessonProgresses.where((p) => p.isCompleted).length;
    final totalLessons = lessonProgresses.length;
    final overallProgress =
        totalLessons > 0 ? completedLessons / totalLessons : 0.0;

    final existingCourseProgress = _courseProgressBox.get(key);

    if (existingCourseProgress != null) {
      final updatedCourseProgress = existingCourseProgress.copyWith(
        overallProgress: overallProgress,
        completedLessons: completedLessons,
        totalLessons: totalLessons,
        lastAccessed: now,
        updatedAt: now,
      );
      await _courseProgressBox.put(key, updatedCourseProgress);
    } else {
      final newCourseProgress = CourseProgress(
        courseId: courseId,
        userId: userId,
        overallProgress: overallProgress,
        completedLessons: completedLessons,
        totalLessons: totalLessons,
        lastAccessed: now,
        createdAt: now,
        updatedAt: now,
      );
      await _courseProgressBox.put(key, newCourseProgress);
    }
  }

  static CourseProgress? getCourseProgress(String courseId, String userId) {
    final key = '${userId}_$courseId';
    return _courseProgressBox.get(key);
  }

  static List<CourseProgress> getAllCourseProgress(String userId) {
    return _courseProgressBox.values
        .where((progress) => progress.userId == userId)
        .toList();
  }

  // Notes Methods
  static Future<void> saveLessonNote(
      String lessonId, String userId, String note) async {
    final key = '${userId}_${lessonId}_note';
    await _notesBox.put(key, note);
  }

  static String? getLessonNote(String lessonId, String userId) {
    final key = '${userId}_${lessonId}_note';
    return _notesBox.get(key);
  }

  static Future<void> deleteLessonNote(String lessonId, String userId) async {
    final key = '${userId}_${lessonId}_note';
    await _notesBox.delete(key);
  }

  // Utility Methods
  static Future<void> clearUserData(String userId) async {
    // Clear lesson progress
    final lessonKeys = _lessonProgressBox.keys
        .where((key) => key.toString().startsWith('${userId}_'))
        .toList();
    await _lessonProgressBox.deleteAll(lessonKeys);

    // Clear course progress
    final courseKeys = _courseProgressBox.keys
        .where((key) => key.toString().startsWith('${userId}_'))
        .toList();
    await _courseProgressBox.deleteAll(courseKeys);

    // Clear notes
    final noteKeys = _notesBox.keys
        .where((key) => key.toString().startsWith('${userId}_'))
        .toList();
    await _notesBox.deleteAll(noteKeys);
  }

  static Future<void> close() async {
    await _lessonProgressBox.close();
    await _courseProgressBox.close();
    await _notesBox.close();
  }

  // Statistics Methods
  static Map<String, dynamic> getUserStats(String userId) {
    final courseProgresses = getAllCourseProgress(userId);
    final totalCourses = courseProgresses.length;
    final completedCourses =
        courseProgresses.where((p) => p.overallProgress >= 1.0).length;
    final totalLessons =
        courseProgresses.fold(0, (sum, p) => sum + p.totalLessons);
    final completedLessons =
        courseProgresses.fold(0, (sum, p) => sum + p.completedLessons);

    return {
      'totalCourses': totalCourses,
      'completedCourses': completedCourses,
      'totalLessons': totalLessons,
      'completedLessons': completedLessons,
      'overallProgress': totalCourses > 0
          ? courseProgresses.fold(0.0, (sum, p) => sum + p.overallProgress) /
              totalCourses
          : 0.0,
    };
  }
}
