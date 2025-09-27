import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../home/tabs/home_tab.dart';
import '../home/tabs/courses_tab.dart';
import '../home/tabs/profile_tab.dart';
import '../instructor/instructor_dashboard.dart';
import '../admin/admin_dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final userRole = auth.role;

        // Role-based tabs
        final tabs = userRole == UserRole.admin
            ? [
                const AdminDashboard(),
                // const CoursesTab(),
                const ProfileTab(),
              ]
            : userRole == UserRole.instructor
                ? [
                    const InstructorDashboard(),
                    const CoursesTab(),
                    const ProfileTab(),
                  ]
                : [
                    const HomeTab(),
                    const CoursesTab(),
                    const ProfileTab(),
                  ];

        // Role-based navigation destinations
        final destinations = userRole == UserRole.admin
            ? const [
                NavigationDestination(
                    icon: Icon(Icons.admin_panel_settings_outlined),
                    selectedIcon: Icon(Icons.admin_panel_settings),
                    label: 'Admin'),
                // NavigationDestination(
                //     icon: Icon(Icons.menu_book_outlined),
                //     selectedIcon: Icon(Icons.menu_book),
                //     label: 'Courses'),
                NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: 'Profile'),
              ]
            : userRole == UserRole.instructor
                ? const [
                    NavigationDestination(
                        icon: Icon(Icons.dashboard_outlined),
                        selectedIcon: Icon(Icons.dashboard),
                        label: 'Dashboard'),
                    NavigationDestination(
                        icon: Icon(Icons.menu_book_outlined),
                        selectedIcon: Icon(Icons.menu_book),
                        label: 'My Courses'),
                    NavigationDestination(
                        icon: Icon(Icons.person_outline),
                        selectedIcon: Icon(Icons.person),
                        label: 'Profile'),
                  ]
                : const [
                    NavigationDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home),
                        label: 'Home'),
                    NavigationDestination(
                        icon: Icon(Icons.menu_book_outlined),
                        selectedIcon: Icon(Icons.menu_book),
                        label: 'Courses'),
                    NavigationDestination(
                        icon: Icon(Icons.person_outline),
                        selectedIcon: Icon(Icons.person),
                        label: 'Profile'),
                  ];

        return Scaffold(
          // appBar: AppBar(
          //   title: Text(userRole == UserRole.instructor
          //       ? 'Instructor Portal'
          //       : 'E-Learning'),
          //   actions: [
          //     // Role indicator
          //     Container(
          //       margin: const EdgeInsets.only(right: 8),
          //       padding:
          //           const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          //       decoration: BoxDecoration(
          //         color: userRole == UserRole.instructor
          //             ? Theme.of(context).colorScheme.secondary
          //             : Theme.of(context).colorScheme.primary,
          //         borderRadius: BorderRadius.circular(16),
          //       ),
          //       child: Text(
          //         userRole == UserRole.instructor ? 'Instructor' : 'Student',
          //         style: TextStyle(
          //           color: Theme.of(context).colorScheme.onPrimary,
          //           fontSize: 12,
          //           fontWeight: FontWeight.bold,
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          body: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: tabs[_index],
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: destinations,
          ),
        );
      },
    );
  }
}
