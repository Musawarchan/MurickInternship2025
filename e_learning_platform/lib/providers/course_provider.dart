import 'package:flutter/material.dart';

import '../models/course.dart';

class CourseProvider extends ChangeNotifier {
  bool _loading = false;
  final List<Course> _allCourses = [];
  final List<Course> _featured = [];

  // Filters
  String _query = '';
  CourseCategory? _category;
  CourseDifficulty? _difficulty;
  bool? _freeOnly;

  // Pagination
  int _page = 1;
  final int _pageSize = 8;
  bool _hasMore = true;

  bool get isLoading => _loading;
  List<Course> get courses => List.unmodifiable(_filteredCourses());
  List<Course> get featured => List.unmodifiable(_featured);
  bool get hasMore => _hasMore;
  bool? get freeOnly => _freeOnly;

  Future<void> loadInitial() async {
    if (_allCourses.isNotEmpty) return;
    _setLoading(true);
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final generated = List.generate(40, (i) => _generateCourse(i));
    _allCourses.clear();
    _allCourses.addAll(generated);
    _featured
      ..clear()
      ..addAll(_allCourses.take(5));
    _page = 1;
    _hasMore = _filteredCourses().length > _page * _pageSize;
    _setLoading(false);
  }

  Future<void> loadMore() async {
    if (!_hasMore || _loading) return;
    _setLoading(true);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _page += 1;
    _hasMore = _filteredCourses().length > _page * _pageSize;
    _setLoading(false);
  }

  void updateQuery(String query) {
    _query = query.trim().toLowerCase();
    _resetPagination();
    notifyListeners();
  }

  void updateCategory(CourseCategory? category) {
    _category = category;
    _resetPagination();
    notifyListeners();
  }

  void updateDifficulty(CourseDifficulty? difficulty) {
    _difficulty = difficulty;
    _resetPagination();
    notifyListeners();
  }

  void updateFreeOnly(bool? freeOnly) {
    _freeOnly = freeOnly;
    _resetPagination();
    notifyListeners();
  }

  void toggleEnroll(String courseId) {
    final idx = _allCourses.indexWhere((c) => c.id == courseId);
    if (idx != -1) {
      _allCourses[idx].isEnrolled = !_allCourses[idx].isEnrolled;
      notifyListeners();
    }
  }

  void updateCourse(Course updatedCourse) {
    final idx = _allCourses.indexWhere((c) => c.id == updatedCourse.id);
    if (idx != -1) {
      _allCourses[idx] = updatedCourse;
      notifyListeners();
    }
  }

  List<Course> _filteredCourses() {
    Iterable<Course> list = _allCourses;
    if (_query.isNotEmpty) {
      list = list.where((c) =>
          c.title.toLowerCase().contains(_query) ||
          c.subtitle.toLowerCase().contains(_query) ||
          c.instructor.toLowerCase().contains(_query));
    }
    if (_category != null) {
      list = list.where((c) => c.category == _category);
    }
    if (_difficulty != null) {
      list = list.where((c) => c.difficulty == _difficulty);
    }
    if (_freeOnly != null) {
      list = list.where((c) => _freeOnly! ? c.isFree : !c.isFree);
    }
    final full = list.toList();
    final end = (_page * _pageSize).clamp(0, full.length);
    return full.sublist(0, end);
  }

  void _resetPagination() {
    _page = 1;
    _hasMore = _filteredCourses().length > _page * _pageSize;
  }

  Course _generateCourse(int i) {
    final categories = CourseCategory.values;
    final difficulties = CourseDifficulty.values;
    final cat = categories[i % categories.length];
    final diff = difficulties[i % difficulties.length];
    final free = i % 3 == 0;
    return Course(
      id: 'c_${i + 1}',
      title: 'Course ${i + 1}',
      subtitle: 'Subtitle ${i + 1}',
      instructor: 'Instructor ${i % 7 + 1}',
      thumbnailUrl: '',
      rating: 3.5 + (i % 15) / 10.0,
      ratingCount: 20 + i * 3,
      isFree: free,
      price: free ? 0 : (9.99 + (i % 5) * 5),
      category: cat,
      difficulty: diff,
      description:
          'This is a comprehensive course number ${i + 1} that covers key concepts and hands-on practice.',
      isEnrolled: false,
    );
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
