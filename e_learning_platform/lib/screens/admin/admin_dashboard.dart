import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/review_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'admin_courses_screen.dart';
import 'admin_reviews_screen.dart';
import 'admin_analytics_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    // Use post-frame callback to avoid setState during build and check mounted state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CourseProvider>().loadInitial();
        context.read<ReviewProvider>().loadReviews();
      }
    });
  }

  @override
  void dispose() {
    // Clean up any pending operations
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   actions: [
      //     IconButton(
      //       onPressed: () {
      //         context.read<AuthProvider>().logout();
      //       },
      //       icon: const Icon(Icons.logout),
      //       tooltip: 'Logout',
      //     ),
      //   ],
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 24,
            ),
            _buildWelcomeSection(),
            // const SizedBox(height: 12),
            _buildStatsCards(),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.ceruleanBlue,
                AppTheme.vividPink,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.ceruleanBlue.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back, ${auth.displayName ?? 'Admin'}!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Here\'s what\'s happening with your platform today.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsCards() {
    return Consumer2<CourseProvider, ReviewProvider>(
      builder: (context, courseProvider, reviewProvider, _) {
        final totalCourses = courseProvider.courses.length;
        final totalReviews = reviewProvider.reviews.length;
        final pendingReviews = reviewProvider.getPendingReviews().length;
        final totalRevenue = totalCourses * 99.99; // Mock revenue calculation

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildStatCard(
              'Total Courses',
              totalCourses.toString(),
              Icons.menu_book,
              AppTheme.ceruleanBlue,
            ),
            _buildStatCard(
              'Total Reviews',
              totalReviews.toString(),
              Icons.star,
              AppTheme.amberOrange,
            ),
            _buildStatCard(
              'Pending Reviews',
              pendingReviews.toString(),
              Icons.pending_actions,
              AppTheme.vividPink,
            ),
            _buildStatCard(
              'Total Revenue',
              '₹${totalRevenue.toStringAsFixed(0)}',
              Icons.attach_money,
              Colors.green,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.trending_up,
                color: Colors.green.shade400,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.5,
          children: [
            _buildActionCard(
              'Manage Courses',
              Icons.menu_book_outlined,
              AppTheme.ceruleanBlue,
              () => _navigateToAdminCourses(),
            ),
            _buildActionCard(
              'Review Management',
              Icons.rate_review_outlined,
              AppTheme.amberOrange,
              () => _navigateToAdminReviews(),
            ),
            _buildActionCard(
              'Analytics',
              Icons.analytics_outlined,
              AppTheme.vividPink,
              () => _navigateToAdminAnalytics(),
            ),
            _buildActionCard(
              'User Management',
              Icons.people_outlined,
              Colors.purple,
              () => _showComingSoon('User Management'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              _buildActivityItem(
                'New course "Advanced Flutter" was created',
                '2 hours ago',
                Icons.add_circle_outline,
                Colors.green,
              ),
              const Divider(),
              _buildActivityItem(
                '5 new reviews pending approval',
                '4 hours ago',
                Icons.pending_actions,
                AppTheme.amberOrange,
              ),
              const Divider(),
              _buildActivityItem(
                'Course "React Basics" completed by 12 students',
                '6 hours ago',
                Icons.school,
                AppTheme.ceruleanBlue,
              ),
              const Divider(),
              _buildActivityItem(
                'Revenue increased by 15% this week',
                '1 day ago',
                Icons.trending_up,
                Colors.green,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
      String title, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAdminCourses() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AdminCoursesScreen(),
      ),
    );
  }

  void _navigateToAdminReviews() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AdminReviewsScreen(),
      ),
    );
  }

  void _navigateToAdminAnalytics() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AdminAnalyticsScreen(),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        backgroundColor: AppTheme.ceruleanBlue,
      ),
    );
  }
}
