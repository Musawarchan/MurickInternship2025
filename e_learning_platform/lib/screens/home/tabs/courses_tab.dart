import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/course.dart';
import '../../../providers/course_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/course_card.dart';
import '../../../theme/app_theme.dart';
import '../../course/course_details_screen.dart';

class CoursesTab extends StatelessWidget {
  const CoursesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CourseProvider, AuthProvider>(
      builder: (context, courseProvider, authProvider, _) {
        final userRole = authProvider.role;

        if (courseProvider.courses.isEmpty && !courseProvider.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback(
              (_) => context.read<CourseProvider>().loadInitial());
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Role-based header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          userRole == UserRole.instructor
                              ? 'Manage Your Courses'
                              : 'Browse Courses',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      if (userRole == UserRole.instructor)
                        Flexible(
                          child: FilledButton.icon(
                            onPressed: () => _showCreateCourseDialog(context),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Create Course'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Search bar (only for students)
                  if (userRole == UserRole.student) ...[
                    TextField(
                      onChanged: (v) =>
                          context.read<CourseProvider>().updateQuery(v),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search courses...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Filters (only for students)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _FilterButton<CourseCategory>(
                          label: 'Category',
                          values: CourseCategory.values,
                          toLabel: (c) => c.name,
                          onChanged: (v) =>
                              context.read<CourseProvider>().updateCategory(v),
                        ),
                        _FilterButton<CourseDifficulty>(
                          label: 'Level',
                          values: CourseDifficulty.values,
                          toLabel: (d) => d.name,
                          onChanged: (v) => context
                              .read<CourseProvider>()
                              .updateDifficulty(v),
                        ),
                        FilterChip(
                          label: const Text('Free Only'),
                          selected: courseProvider.freeOnly == true,
                          onSelected: (v) => context
                              .read<CourseProvider>()
                              .updateFreeOnly(v ? true : null),
                        ),
                        FilterChip(
                          label: const Text('Paid Only'),
                          selected: courseProvider.freeOnly == false,
                          onSelected: (v) => context
                              .read<CourseProvider>()
                              .updateFreeOnly(v ? false : null),
                        ),
                      ],
                    ),
                  ],

                  // Instructor-specific content
                  if (userRole == UserRole.instructor) ...[
                    _buildInstructorStats(context),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
            Expanded(
              child: userRole == UserRole.instructor
                  ? _buildInstructorCoursesGrid(context, courseProvider)
                  : _buildStudentCoursesGrid(context, courseProvider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInstructorStats(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Use Wrap for smaller screens to prevent overflow
          if (constraints.maxWidth < 600) {
            return Wrap(
              alignment: WrapAlignment.spaceEvenly,
              children: [
                _buildStatItem(context, 'Courses', '8', Icons.menu_book),
                _buildStatItem(context, 'Students', '245', Icons.people),
                _buildStatItem(context, 'Rating', '4.8', Icons.star),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: _buildStatItem(
                    context, 'Total Courses', '8', Icons.menu_book),
              ),
              Container(
                width: 1,
                height: 40,
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
              Expanded(
                child: _buildStatItem(context, 'Students', '245', Icons.people),
              ),
              Container(
                width: 1,
                height: 40,
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
              Expanded(
                child: _buildStatItem(context, 'Avg Rating', '4.8', Icons.star),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructorCoursesGrid(
      BuildContext context, CourseProvider courseProvider) {
    // Mock instructor courses (in real app, filter by instructor ID)
    final instructorCourses = courseProvider.featured.take(6).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: instructorCourses.isEmpty
          ? _buildEmptyState(context, 'No courses created yet',
              'Create your first course to get started')
          : LayoutBuilder(
              builder: (context, constraints) {
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _getCrossAxisCount(constraints.maxWidth),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.55
                      // _getChildAspectRatio(constraints.maxWidth),
                      ),
                  itemCount: instructorCourses.length,
                  itemBuilder: (context, index) => _buildInstructorCourseCard(
                    context,
                    instructorCourses[index],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInstructorCourseCard(BuildContext context, Course course) {
    final scheme = Theme.of(context).colorScheme;
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              ],
            ),
          ),
          // Course Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Title
                  Text(
                    course.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              _showCourseManagementDialog(context, course),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Manage'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(
                          onPressed: () =>
                              _showAnalyticsDialog(context, course),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Analytics'),
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
  }

  Widget _buildStudentCoursesGrid(
      BuildContext context, CourseProvider courseProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: courseProvider.courses.isEmpty
          ? _buildEmptyState(context, 'No courses found',
              'Try adjusting your search or filters')
          : NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollEndNotification &&
                    notification.metrics.pixels >=
                        notification.metrics.maxScrollExtent - 200) {
                  context.read<CourseProvider>().loadMore();
                }
                return false;
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            _getCrossAxisCount(constraints.maxWidth),
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.6
                        //
                        ),
                    itemCount: courseProvider.courses.length +
                        (courseProvider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= courseProvider.courses.length) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return CourseCard(
                        course: courseProvider.courses[index],
                        onViewDetails: () => Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => CourseDetailsScreen(
                                course: courseProvider.courses[index]),
                            transitionsBuilder: (_, animation, __, child) =>
                                FadeTransition(
                                    opacity: animation, child: child),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  int _getCrossAxisCount(double width) {
    return 2; // Always 2 columns as requested
  }

  void _showCreateCourseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Course'),
        content: const Text(
            'This feature will allow you to create and publish new courses. Coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCourseManagementDialog(BuildContext context, Course course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Manage ${course.title}'),
        content: const Text(
            'Edit course content, manage students, and update settings. Coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAnalyticsDialog(BuildContext context, Course course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Analytics for ${course.title}'),
        content: const Text(
            'View detailed analytics including student progress, ratings, and revenue. Coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _FilterButton<T> extends StatelessWidget {
  final String label;
  final List<T> values;
  final String Function(T) toLabel;
  final void Function(T?) onChanged;

  const _FilterButton({
    required this.label,
    required this.values,
    required this.toLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T?>(
      onSelected: onChanged,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 16),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(value: null, child: Text('All $label')),
        ...values.map((v) => PopupMenuItem(value: v, child: Text(toLabel(v)))),
      ],
    );
  }
}
