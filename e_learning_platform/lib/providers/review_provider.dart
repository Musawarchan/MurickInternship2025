import 'package:flutter/material.dart';
import '../models/review.dart';

class ReviewProvider extends ChangeNotifier {
  final List<Review> _reviews = [];
  bool _loading = false;

  List<Review> get reviews => List.unmodifiable(_reviews);
  bool get isLoading => _loading;

  // Mock data initialization
  void loadReviews() {
    _setLoading(true);

    // Generate mock reviews
    final mockReviews = List.generate(15, (index) {
      final courseIds = ['c_1', 'c_2', 'c_3', 'c_4', 'c_5'];
      final courseId = courseIds[index % courseIds.length];
      final ratings = [4, 5, 3, 5, 4, 5, 2, 4, 5, 3, 5, 4, 5, 4, 3];
      final comments = [
        'Great course! Very informative and well-structured.',
        'Excellent content and clear explanations.',
        'Good course but could use more examples.',
        'Amazing instructor and quality content.',
        'Very helpful for beginners.',
        'Outstanding course, highly recommended!',
        'Could be better organized.',
        'Good value for money.',
        'Perfect for my learning needs.',
        'Decent course but needs more practice exercises.',
        'Fantastic course with real-world examples.',
        'Well-paced and easy to follow.',
        'Excellent teaching methodology.',
        'Good course overall.',
        'Helpful but could use more advanced topics.',
      ];
      final userNames = [
        'John Doe',
        'Jane Smith',
        'Mike Johnson',
        'Sarah Wilson',
        'David Brown',
        'Emily Davis',
        'Chris Miller',
        'Lisa Garcia',
        'Tom Anderson',
        'Amy Taylor',
        'Mark Thomas',
        'Jessica White',
        'Kevin Harris',
        'Rachel Martin',
        'Daniel Lee'
      ];

      return Review(
        id: 'review_${index + 1}',
        courseId: courseId,
        userId: 'user_${index + 1}',
        userName: userNames[index],
        rating: ratings[index],
        comment: comments[index],
        createdAt: DateTime.now().subtract(Duration(days: index * 2)),
        approved: index < 12, // First 12 reviews are approved
      );
    });

    _reviews.clear();
    _reviews.addAll(mockReviews);
    _setLoading(false);
  }

  void addReview(Review review) {
    _reviews.insert(0, review);
    notifyListeners();
  }

  void updateReview(String reviewId, Review updatedReview) {
    final index = _reviews.indexWhere((r) => r.id == reviewId);
    if (index != -1) {
      _reviews[index] = updatedReview;
      notifyListeners();
    }
  }

  void deleteReview(String reviewId) {
    _reviews.removeWhere((r) => r.id == reviewId);
    notifyListeners();
  }

  void approveReview(String reviewId) {
    final index = _reviews.indexWhere((r) => r.id == reviewId);
    if (index != -1) {
      _reviews[index] = _reviews[index].copyWith(approved: true);
      notifyListeners();
    }
  }

  void rejectReview(String reviewId) {
    final index = _reviews.indexWhere((r) => r.id == reviewId);
    if (index != -1) {
      _reviews[index] = _reviews[index].copyWith(approved: false);
      notifyListeners();
    }
  }

  List<Review> getReviewsForCourse(String courseId) {
    return _reviews.where((r) => r.courseId == courseId && r.approved).toList();
  }

  List<Review> getPendingReviews() {
    return _reviews.where((r) => !r.approved).toList();
  }

  double getAverageRatingForCourse(String courseId) {
    final courseReviews = getReviewsForCourse(courseId);
    if (courseReviews.isEmpty) return 0.0;

    final totalRating =
        courseReviews.fold(0, (sum, review) => sum + review.rating);
    return totalRating / courseReviews.length;
  }

  int getReviewCountForCourse(String courseId) {
    return getReviewsForCourse(courseId).length;
  }

  Map<int, int> getRatingDistributionForCourse(String courseId) {
    final courseReviews = getReviewsForCourse(courseId);
    final distribution = <int, int>{};

    for (int i = 1; i <= 5; i++) {
      distribution[i] = courseReviews.where((r) => r.rating == i).length;
    }

    return distribution;
  }

  void _setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }
}
