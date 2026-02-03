import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tvstream/l10n/app_localizations.dart';
import 'home/home_screen.dart';
import 'settings/settings_screen.dart';

import 'favorites/favorites_screen.dart';
import 'radio/radio_screen.dart';

import '../widgets/gradient_background.dart';
import '../../core/app_theme.dart';

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
    const FavoritesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: GradientBackground(
        child: Stack(
          children: [
            // Main Content
            IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
            
            // Custom Lightweight Floating Nav Bar
            Positioned(
              left: 15,
              right: 15,
              bottom: 40,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.glassSurface,
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(Icons.tv, Icons.tv_outlined, 0),
                        _buildNavItem(Icons.radio, Icons.radio_outlined, 1),
                        _buildNavItem(Icons.favorite, Icons.favorite_border, 2),
                        _buildNavItem(Icons.settings, Icons.settings_outlined, 3),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData selectedIcon, IconData unselectedIcon, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: isSelected 
          ? BoxDecoration(
              color: AppTheme.accentGold.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            )
          : const BoxDecoration(
              shape: BoxShape.circle,
            ),
        child: Icon(
          isSelected ? selectedIcon : unselectedIcon,
          color: isSelected ? AppTheme.accentGold : Colors.white.withValues(alpha: 0.6),
          size: 26,
        ),
      ),
    );
  }
}
