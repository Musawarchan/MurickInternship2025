import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/course.dart';
import '../../providers/course_provider.dart';
import '../../theme/app_theme.dart';

class CourseDetailsScreen extends StatelessWidget {
  final Course course;
  const CourseDetailsScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    final current = provider.courses
        .firstWhere((c) => c.id == course.id, orElse: () => course);

    return Scaffold(
      // appBar: AppBar(title: const Text('Course Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
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
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.play_circle_fill,
                  size: 64, color: Colors.white70),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            current.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'By ${current.instructor}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Row(children: [
            Icon(Icons.star, size: 18, color: Colors.amber.shade600),
            const SizedBox(width: 4),
            Text(
              '${current.rating.toStringAsFixed(1)} (${current.ratingCount} ratings)',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Chip(
              label: Text(
                current.isFree
                    ? 'Free'
                    : '\u20B9${current.price.toStringAsFixed(2)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]),
          const SizedBox(height: 16),
          Text(
            current.description,
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () =>
                context.read<CourseProvider>().toggleEnroll(current.id),
            child: Text(current.isEnrolled ? 'Enrolled' : 'Enroll'),
          ),
          const SizedBox(height: 24),
          Text('Lessons', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...List.generate(
              8,
              (i) => ListTile(
                  leading: const Icon(Icons.play_circle_outline),
                  title: Text('Lesson ${i + 1}'),
                  subtitle: const Text('10 min'))),
          const SizedBox(height: 16),
          Text('Ratings & Reviews',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...List.generate(
              3,
              (i) => ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text('User ${i + 1}'),
                    subtitle: const Text('Great course! Learned a lot.'),
                  )),
        ],
      ),
    );
  }
}
