class Review {
  final String id;
  final String courseId;
  final String userId;
  final String userName;
  final int rating; // 1-5
  final String comment;
  final DateTime createdAt;
  final bool approved; // for moderation (mock)

  Review({
    required this.id,
    required this.courseId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.approved = true,
  }) : assert(rating >= 1 && rating <= 5);

  Review copyWith({
    String? id,
    String? courseId,
    String? userId,
    String? userName,
    int? rating,
    String? comment,
    DateTime? createdAt,
    bool? approved,
  }) {
    return Review(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      approved: approved ?? this.approved,
    );
  }
}
