import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';
import '../providers/auth_provider.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onViewDetails;
  const CourseCard(
      {super.key, required this.course, required this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final userId = authProvider.user?.id ?? 'anonymous';
        final courseProgress =
            ProgressService.getCourseProgress(course.id, userId);
        final progressPercentage = courseProgress?.overallProgress ?? 0.0;
        final isEnrolled = course.isEnrolled;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Image/Thumbnail
              Container(
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.ceruleanBlue.withOpacity(0.9),
                      AppTheme.vividPink.withOpacity(0.7),
                      AppTheme.amberOrange.withOpacity(0.6),
                    ],
                  ),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Stack(
                  children: [
                    // Play button overlay
                    const Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        size: 48,
                        color: Colors.white70,
                      ),
                    ),
                    // Price badge
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: course.isFree
                              ? AppTheme.sunnyYellow
                              : AppTheme.royalBlue,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          course.isFree
                              ? 'FREE'
                              : '₹${course.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: course.isFree ? Colors.black : Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Difficulty badge
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          course.difficulty.name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Progress indicator for enrolled courses
                    if (isEnrolled && progressPercentage > 0)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(16),
                            ),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progressPercentage,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Course Content
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course Title
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              course.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isEnrolled)
                            Icon(
                              progressPercentage >= 1.0
                                  ? Icons.check_circle
                                  : Icons.play_circle,
                              color: progressPercentage >= 1.0
                                  ? Colors.green
                                  : scheme.primary,
                              size: 20,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Instructor
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 16,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              course.instructor,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Rating and Students
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${course.rating.toStringAsFixed(1)}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.people_outline,
                            size: 16,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${course.ratingCount}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),

                      // Progress info for enrolled courses
                      if (isEnrolled && progressPercentage > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Progress: ${(progressPercentage * 100).toInt()}%',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: scheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const Spacer(),
                            Text(
                              '${courseProgress?.completedLessons ?? 0}/${courseProgress?.totalLessons ?? 0} lessons',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progressPercentage,
                          backgroundColor: scheme.outline.withOpacity(0.3),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(scheme.primary),
                        ),
                      ],

                      const Spacer(),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: onViewDetails,
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                isEnrolled ? 'Continue' : 'View Details',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Consumer<CourseProvider>(
                              builder: (context, provider, child) =>
                                  FilledButton(
                                onPressed: () =>
                                    provider.toggleEnroll(course.id),
                                style: FilledButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  course.isEnrolled ? 'Enrolled' : 'Enroll',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
