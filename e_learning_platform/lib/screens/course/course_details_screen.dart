import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../models/course.dart';
import '../../models/lesson.dart';
import '../../providers/course_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_video_player.dart';
import '../../widgets/lesson_navigation.dart';
import '../../widgets/notes_resources_section.dart';
import '../../services/progress_service.dart';

class CourseDetailsScreen extends StatefulWidget {
  final Course course;
  const CourseDetailsScreen({super.key, required this.course});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  Lesson? _currentLesson;
  bool _showSidebar = true;
  bool _isEnrolled = false;

  @override
  void initState() {
    super.initState();
    _isEnrolled = widget.course.isEnrolled;
    _initializeLessons();
  }

  void _initializeLessons() {
    // Generate mock lessons for the course
    final lessons = List.generate(8, (index) {
      return Lesson(
        id: '${widget.course.id}_lesson_${index + 1}',
        courseId: widget.course.id,
        title: 'Lesson ${index + 1}: ${_getLessonTitle(index)}',
        description:
            'This lesson covers ${_getLessonTitle(index).toLowerCase()} concepts and provides hands-on practice.',
        type: index % 3 == 0 ? LessonType.video : LessonType.pdf,
        contentUrl: index % 3 == 0
            ? 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'
            : 'https://example.com/lesson-${index + 1}.pdf',
        duration: 300 + (index * 60), // 5-12 minutes
        order: index + 1,
        isPreview: index < 2, // First 2 lessons are preview
        resources: _getMockResources(index),
      );
    });

    // Update course with lessons
    final updatedCourse = widget.course.copyWith(
      lessons: lessons,
      totalDuration:
          lessons.fold<int>(0, (sum, lesson) => sum + lesson.duration),
      lessonCount: lessons.length,
    );

    // Set first lesson as current
    if (lessons.isNotEmpty) {
      _currentLesson = lessons.first;
    }

    // Update course in provider
    context.read<CourseProvider>().updateCourse(updatedCourse);
  }

  String _getLessonTitle(int index) {
    final titles = [
      'Introduction to Course',
      'Basic Concepts',
      'Advanced Topics',
      'Practical Examples',
      'Best Practices',
      'Common Mistakes',
      'Real-world Applications',
      'Course Summary',
    ];
    return titles[index % titles.length];
  }

  List<String> _getMockResources(int index) {
    return [
      'https://example.com/lesson-${index + 1}-notes.pdf',
      'https://example.com/lesson-${index + 1}-exercises.pdf',
    ];
  }

  void _onLessonSelected(Lesson lesson) {
    setState(() {
      _currentLesson = lesson;
    });
  }

  void _toggleSidebar() {
    setState(() {
      _showSidebar = !_showSidebar;
    });
  }

  void _onEnroll() {
    setState(() {
      _isEnrolled = true;
    });
    context.read<CourseProvider>().toggleEnroll(widget.course.id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Successfully enrolled in course!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    if (!_isEnrolled) {
      return _buildEnrollmentScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.title),
        actions: [
          IconButton(
            onPressed: _toggleSidebar,
            icon: Icon(_showSidebar ? Icons.menu_open : Icons.menu),
            tooltip: 'Toggle lesson list',
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar for tablets, drawer for mobile
          if (isTablet && _showSidebar)
            LessonNavigation(
              lessons: widget.course.lessons,
              currentLesson: _currentLesson,
              onLessonSelected: _onLessonSelected,
              isDrawer: false,
            ),

          // Main content
          Expanded(
            child: _currentLesson != null
                ? _buildLessonContent()
                : _buildCourseOverview(),
          ),
        ],
      ),
      // Drawer for mobile
      drawer: !isTablet
          ? LessonNavigation(
              lessons: widget.course.lessons,
              currentLesson: _currentLesson,
              onLessonSelected: _onLessonSelected,
              isDrawer: true,
            )
          : null,
    );
  }

  Widget _buildEnrollmentScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course thumbnail
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    size: 64,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Course info
            Text(
              widget.course.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'By ${widget.course.instructor}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),

            // Rating and price
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber.shade600),
                const SizedBox(width: 4),
                Text('${widget.course.rating.toStringAsFixed(1)}'),
                const SizedBox(width: 8),
                Text('(${widget.course.ratingCount} ratings)'),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.course.isFree
                        ? Colors.green
                        : Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    widget.course.isFree
                        ? 'FREE'
                        : '₹${widget.course.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Description
            Text(
              'About this course',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.course.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            // Course stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Lessons',
                      '${widget.course.lessonCount}',
                      Icons.menu_book_outlined,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Duration',
                      widget.course.formattedTotalDuration,
                      Icons.access_time_outlined,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Level',
                      widget.course.difficulty.name,
                      Icons.trending_up_outlined,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Enroll button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _onEnroll,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  widget.course.isFree ? 'Start Learning' : 'Enroll Now',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildLessonContent() {
    return Column(
      children: [
        // Video player
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: CustomVideoPlayer(
              lesson: _currentLesson!,
              autoPlay: false,
              onProgressUpdate: () {
                setState(() {}); // Refresh to update progress
              },
            ),
          ),
        ),

        // Lesson info and notes/resources
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Lesson title and description
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentLesson!.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            _getLessonTypeIcon(_currentLesson!.type),
                            size: 16,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _currentLesson!.formattedDuration,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                          const Spacer(),
                          if (_currentLesson!.isPreview)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Preview',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentLesson!.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Notes and resources
                Expanded(
                  child: NotesResourcesSection(
                    lesson: _currentLesson!,
                    resources: _currentLesson!.resources,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseOverview() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Course Overview',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: AnimationLimiter(
              child: ListView.builder(
                itemCount: widget.course.lessons.length,
                itemBuilder: (context, index) {
                  final lesson = widget.course.lessons[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: _buildLessonOverviewItem(lesson, index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonOverviewItem(Lesson lesson, int index) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final userId = authProvider.user?.id ?? 'anonymous';
        final progress = ProgressService.getLessonProgress(lesson.id, userId);
        final isCompleted = progress?.isCompleted ?? false;
        final progressPercentage = progress?.progress ?? 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            color:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _onLessonSelected(lesson),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Lesson number and status
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .outline
                                .withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: isCompleted
                            ? Icon(
                                Icons.check,
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: 20,
                              )
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Lesson info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lesson.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                _getLessonTypeIcon(lesson.type),
                                size: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                lesson.formattedDuration,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                              if (lesson.isPreview) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Preview',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (progressPercentage > 0 && !isCompleted) ...[
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: progressPercentage,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withOpacity(0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Arrow icon
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getLessonTypeIcon(LessonType type) {
    switch (type) {
      case LessonType.video:
        return Icons.play_circle_outline;
      case LessonType.pdf:
        return Icons.picture_as_pdf_outlined;
      case LessonType.text:
        return Icons.article_outlined;
      case LessonType.quiz:
        return Icons.quiz_outlined;
    }
  }
}
