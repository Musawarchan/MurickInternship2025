import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../widgets/custom_form_field.dart';
import '../../../widgets/auth_button.dart';
import '../../../theme/app_theme.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final profile = context.read<ProfileProvider>();
      profile.initializeProfile(
        auth.displayName ?? 'Your Name',
        auth.email ?? 'you@example.com',
      );
      _nameController.text = auth.displayName ?? 'Your Name';
      _emailController.text = auth.email ?? 'you@example.com';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    await context.read<ProfileProvider>().updateProfile(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ProfileProvider>(
      builder: (context, auth, profile, child) {
        final userRole = auth.role;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Header
            _buildProfileHeader(context, auth, userRole),
            const SizedBox(height: 24),

            // Role-specific content
            if (userRole == UserRole.instructor) ...[
              _buildInstructorSection(context),
              const SizedBox(height: 24),
            ] else ...[
              _buildStudentSection(context),
              const SizedBox(height: 24),
            ],

            // Profile Form
            _buildProfileForm(context, profile),

            // Theme Settings
            const SizedBox(height: 24),
            _buildThemeSettings(context, auth),

            // Role-specific actions
            const SizedBox(height: 24),
            _buildRoleActions(context, userRole),

            // Logout Section
            const SizedBox(height: 32),
            _buildLogoutSection(context, auth),
          ],
        );
      },
    );
  }

  Widget _buildProfileHeader(
      BuildContext context, AuthProvider auth, UserRole? userRole) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: userRole == UserRole.instructor
              ? [AppTheme.vividPink, AppTheme.amberOrange]
              : [AppTheme.ceruleanBlue, AppTheme.royalBlue],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              (auth.displayName ?? 'Y')[0].toUpperCase(),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: userRole == UserRole.instructor
                    ? scheme.onSecondary
                    : scheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            auth.displayName ?? 'Your Name',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: userRole == UserRole.instructor
                      ? scheme.onSecondary
                      : scheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              userRole == UserRole.instructor ? 'INSTRUCTOR' : 'STUDENT',
              style: TextStyle(
                color: userRole == UserRole.instructor
                    ? scheme.onSecondary
                    : scheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructorSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Instructor Statistics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                  context, 'Courses', '8', Icons.menu_book, Colors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                  context, 'Students', '245', Icons.people, Colors.green),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(context, 'Revenue', '₹12K',
                  Icons.attach_money, Colors.orange),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStudentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Learning Progress',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                  context, 'Enrolled', '12', Icons.bookmark, Colors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                  context, 'Completed', '8', Icons.check_circle, Colors.green),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(context, 'Certificates', '5',
                  Icons.workspace_premium, Colors.purple),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value,
      IconData icon, Color color) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm(BuildContext context, ProfileProvider profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Information',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Form(
          key: _formKey,
          child: Column(
            children: [
              CustomFormField(
                controller: _nameController,
                labelText: 'Name',
                prefixIcon: const Icon(Icons.person_outlined),
              ),
              const SizedBox(height: 16),
              CustomFormField(
                controller: _emailController,
                labelText: 'Email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              const SizedBox(height: 24),
              if (profile.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          profile.error!,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              AuthButton(
                text: 'Save Changes',
                onPressed: _handleSave,
                isLoading: profile.isLoading,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSettings(BuildContext context, AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Appearance',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildThemeOption(
                context,
                'Light Theme',
                'Use light colors',
                Icons.light_mode,
                ThemeMode.light,
                authProvider.themeMode,
                () => authProvider.setThemeMode(ThemeMode.light),
              ),
              const Divider(),
              _buildThemeOption(
                context,
                'Dark Theme',
                'Use dark colors',
                Icons.dark_mode,
                ThemeMode.dark,
                authProvider.themeMode,
                () => authProvider.setThemeMode(ThemeMode.dark),
              ),
              const Divider(),
              _buildThemeOption(
                context,
                'System Theme',
                'Follow system setting',
                Icons.brightness_auto,
                ThemeMode.system,
                authProvider.themeMode,
                () => authProvider.setThemeMode(ThemeMode.system),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    ThemeMode mode,
    ThemeMode currentMode,
    VoidCallback onTap,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final isSelected = currentMode == mode;

    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? scheme.primary.withOpacity(0.1)
              : scheme.onSurfaceVariant.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isSelected ? scheme.primary : null,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: scheme.primary,
              size: 20,
            )
          : Icon(
              Icons.radio_button_unchecked,
              color: scheme.onSurfaceVariant,
              size: 20,
            ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildLogoutSection(BuildContext context, AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.error.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.logout,
                      color: Theme.of(context).colorScheme.error,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sign Out',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                        ),
                        Text(
                          'Sign out of your account',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context, auth),
                  icon: Icon(
                    Icons.logout,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  label: Text(
                    'Sign Out',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleActions(BuildContext context, UserRole? userRole) {
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
        if (userRole == UserRole.instructor) ...[
          _buildActionTile(
            context,
            'Create New Course',
            'Add a new course to your catalog',
            Icons.add_circle,
            Colors.green,
            () => _showCreateCourseDialog(context),
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            context,
            'Manage Students',
            'View and manage enrolled students',
            Icons.people_alt,
            Colors.blue,
            () => _showManageStudentsDialog(context),
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            context,
            'View Analytics',
            'Check course performance metrics',
            Icons.analytics,
            Colors.purple,
            () => _showAnalyticsDialog(context),
          ),
        ] else ...[
          _buildActionTile(
            context,
            'My Learning',
            'Continue your enrolled courses',
            Icons.play_circle,
            Colors.green,
            () => _showMyLearningDialog(context),
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            context,
            'Certificates',
            'View your earned certificates',
            Icons.workspace_premium,
            Colors.orange,
            () => _showCertificatesDialog(context),
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            context,
            'Learning Goals',
            'Set and track your goals',
            Icons.flag,
            Colors.blue,
            () => _showGoalsDialog(context),
          ),
        ],
      ],
    );
  }

  Widget _buildActionTile(BuildContext context, String title, String subtitle,
      IconData icon, Color color, VoidCallback onTap) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.arrow_forward_ios,
          size: 16, color: scheme.onSurfaceVariant),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outline.withOpacity(0.2)),
      ),
    );
  }

  // Dialog methods
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

  void _showManageStudentsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Students'),
        content:
            const Text('View and manage your enrolled students. Coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAnalyticsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Course Analytics'),
        content: const Text(
            'View detailed analytics and reports for your courses. Coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showMyLearningDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('My Learning'),
        content: const Text(
            'Continue your enrolled courses and track your progress. Coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCertificatesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Certificates'),
        content: const Text(
            'View and download your earned certificates. Coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showGoalsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Learning Goals'),
        content: const Text(
            'Set and track your learning goals and milestones. Coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            const Text('Sign Out'),
          ],
        ),
        content: const Text(
            'Are you sure you want to sign out? You will need to sign in again to access your account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              auth.logout();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
