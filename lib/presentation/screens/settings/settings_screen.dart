import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tvstream/l10n/app_localizations.dart';

import '../../../logic/localization_cubit.dart';
import '../../../core/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          l10n.settingsTab,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Language Section
          _buildSectionHeader('اللغة والإعدادات العامة'),
          const SizedBox(height: 12),
          _buildSettingsCard(
            child: ListTile(
              leading: const Icon(Icons.language_rounded, color: AppTheme.primaryGreen),
              title: Text(l10n.language, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              trailing: DropdownButton<String>(
                value: Localizations.localeOf(context).languageCode,
                dropdownColor: Colors.white,
                style: GoogleFonts.cairo(color: AppTheme.textMain, fontWeight: FontWeight.bold),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    context.read<LocalizationCubit>().switchLanguage(newValue);
                  }
                },
                items: const [
                  DropdownMenuItem(value: 'ar', child: Text('العربية')),
                  DropdownMenuItem(value: 'fr', child: Text('Français')),
                ],
                underline: const SizedBox(),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // About Section
          _buildSectionHeader('عن التطبيق'),
          const SizedBox(height: 12),
          _buildSettingsCard(
            child: ListTile(
              leading: const Icon(Icons.info_outline_rounded, color: AppTheme.accentGold),
              title: Text('الإصدار', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              subtitle: Text('TV Stream v1.0.0', style: GoogleFonts.cairo(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          color: AppTheme.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.surface, width: 2),
      ),
      child: child,
    );
  }
}
