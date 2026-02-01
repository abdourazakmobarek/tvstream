import 'package:flutter/material.dart';
import 'package:tvstream/l10n/app_localizations.dart';
import 'home/home_screen.dart';
import 'settings/settings_screen.dart';

import 'favorites/favorites_screen.dart'; // Import Favorites Screen
import 'radio/radio_screen.dart'; // Import Radio Screen

import '../widgets/gradient_background.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const RadioScreen(), 
    const FavoritesScreen(), // Favorites Tab
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent, // Transparent to show gradient if valid, but here we will wrap body
      body: GradientBackground(
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.tv),
            selectedIcon: const Icon(Icons.tv_outlined),
            label: l10n.homeTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.radio_outlined),
            selectedIcon: const Icon(Icons.radio),
            label: l10n.radioTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_outline),
            selectedIcon: const Icon(Icons.favorite),
            label: l10n.favoritesTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.settingsTab,
          ),
        ],
      ),
    );
  }
}
