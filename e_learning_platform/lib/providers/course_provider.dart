import 'package:flutter/material.dart';

import '../models/course.dart';

class CourseProvider extends ChangeNotifier {
  bool _loading = false;
  final List<Course> _allCourses = [];
  final List<Course> _featured = [];

  bool get isLoading => _loading;
  List<Course> get courses => List.unmodifiable(_allCourses);
  List<Course> get featured => List.unmodifiable(_featured);

  Future<void> loadInitial() async {
    if (_allCourses.isNotEmpty) return;
    _setLoading(true);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final generated = List.generate(
        12,
        (i) => Course(
              id: 'c_${i + 1}',
              title: 'Course ${(i + 1)}',
              subtitle: 'Subtitle ${(i + 1)}',
              thumbnailUrl: '',
            ));
    _allCourses.clear();
    _allCourses.addAll(generated);
    _featured
      ..clear()
      ..addAll(generated.take(5));
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
