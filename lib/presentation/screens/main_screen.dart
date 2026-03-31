import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tvstream/l10n/app_localizations.dart';
import 'home/home_screen.dart';
import 'settings/settings_screen.dart';

import 'favorites/favorites_screen.dart';
import 'radio/radio_screen.dart';

import '../../core/app_theme.dart';
import '../widgets/animated_gradient_background.dart';

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

    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true, // Let screens flow under the bottom nav bar
        body: Stack(
          children: [
            // Main Content
            IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
            
            // New Floating Glassmorphic Bottom Nav Bar
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24), // Float above edge
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32), // Pill shape
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: Container(
                      height: 75, // Slimmer profile
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 500), // Limit width on tablets
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.65), // More translucent
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
            ),
          ],
        ),
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
