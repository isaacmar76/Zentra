import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zentra/core/theme/theme_provider.dart';
import 'package:zentra/features/dashboard/screens/dashboard_services_screen.dart';
import 'package:zentra/features/projects/screens/projects_list_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardServicesScreen(),
    const ProjectsListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentPalette;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: theme.secondary,
        unselectedItemColor: theme.textDark.withOpacity(0.5),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            activeIcon: Icon(Icons.folder),
            label: 'Proyectos',
          ),
        ],
      ),
    );
  }
}
