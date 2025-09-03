import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/course_provider.dart';

class CoursesTab extends StatelessWidget {
  const CoursesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    if (provider.courses.isEmpty && !provider.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => context.read<CourseProvider>().loadInitial());
    }
    if (provider.isLoading && provider.courses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: provider.courses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final course = provider.courses[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.menu_book),
            title: Text(course.title),
            subtitle: Text(course.subtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        );
      },
    );
  }
}
