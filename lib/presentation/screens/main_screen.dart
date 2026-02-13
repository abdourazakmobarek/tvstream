import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  List<Widget> get _screens => [
    HomeScreen(onRadioTab: () => setState(() => _currentIndex = 1)),
    const RadioScreen(), 
    const FavoritesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Main Content
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          
          // New Modern Bottom Nav Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: 90, // Taller for bottom safe area
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 600), // Limit width on tablets
                  padding: const EdgeInsets.only(bottom: 20, left: 30, right: 30),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildNavItem(Icons.home_rounded, Icons.home_outlined, 0, l10n.homeTab),
                      _buildNavItem(Icons.radio_rounded, Icons.radio_outlined, 1, l10n.radioTab),
                      _buildNavItem(Icons.favorite_rounded, Icons.favorite_outline_rounded, 2, l10n.favoritesTab),
                      _buildNavItem(Icons.settings_rounded, Icons.settings_outlined, 3, l10n.settingsTab),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData selectedIcon, IconData unselectedIcon, int index, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppTheme.primaryGreen : AppTheme.textSecondary;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? selectedIcon : unselectedIcon,
            color: color,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
