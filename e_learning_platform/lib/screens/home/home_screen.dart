import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../home/tabs/home_tab.dart';
import '../home/tabs/courses_tab.dart';
import '../home/tabs/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const HomeTab(),
      const CoursesTab(),
      const ProfileTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Learning'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') context.read<AuthProvider>().logout();
              if (value == 'theme_light')
                context.read<AuthProvider>().setThemeMode(ThemeMode.light);
              if (value == 'theme_dark')
                context.read<AuthProvider>().setThemeMode(ThemeMode.dark);
              if (value == 'theme_system')
                context.read<AuthProvider>().setThemeMode(ThemeMode.system);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'theme_light', child: Text('Light theme')),
              PopupMenuItem(value: 'theme_dark', child: Text('Dark theme')),
              PopupMenuItem(value: 'theme_system', child: Text('System theme')),
              PopupMenuDivider(),
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          )
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: tabs[_index],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
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
        ],
      ),
    );
  }
}
