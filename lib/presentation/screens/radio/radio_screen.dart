import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:tvstream/l10n/app_localizations.dart';
import 'dart:ui';
import '../../widgets/bouncing_wrapper.dart';

import '../../../logic/channels_cubit.dart';
import '../../../data/models/channel.dart';
import '../../../core/app_theme.dart';

class RadioScreen extends StatefulWidget {
  const RadioScreen({super.key});

  @override
  State<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent, // Allow gradient from MainScreen
      appBar: AppBar(
        title: Text(
          l10n.mauritanianRadio,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocBuilder<ChannelsCubit, ChannelsState>(
        builder: (context, state) {
          if (state is ChannelsLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
          }

          if (state is ChannelsLoaded) {
            final radioStations = state.radioChannels;
            return Column(
              children: [
                // Category Filters
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        _buildCategoryChip(l10n.allCategories, null),
                        const SizedBox(width: 8),
                        _buildCategoryChip(l10n.news, 'News'),
                        const SizedBox(width: 8),
                        _buildCategoryChip(l10n.religious, 'Religious'),
                        const SizedBox(width: 8),
                        _buildCategoryChip(l10n.culture, 'Culture'),
                      ],
                    ),
                  ),
                ),
                // Radio Stations List
                Expanded(
                  child: AnimationLimiter(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                      itemCount: radioStations.length,
                      itemBuilder: (context, index) {
                        final station = radioStations[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 500),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: RadioStationCard(station: station),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }

          return Center(child: Text(l10n.errorLoading));
        },
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? value) {
    final isSelected = _selectedCategory == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen : AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class RadioStationCard extends StatelessWidget {
  final Channel station;
  const RadioStationCard({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BouncingWrapper(
      onTap: () {
        // We will need to define a tap action later if desired, or let the Play button handle it.
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.4), // Glass effect
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
      child: Row(
        children: [
          // Play Button
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow_rounded, color: AppTheme.textSecondary, size: 32),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Localizations.localeOf(context).languageCode == 'ar' ? station.nameAr : station.name,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  station.slogan ?? l10n.radioSlogan,
                  style: GoogleFonts.cairo(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              image: DecorationImage(
                image: station.logoUrl.startsWith('http')
                    ? CachedNetworkImageProvider(station.logoUrl)
                    : AssetImage(station.logoUrl) as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
            ),
          ),
        ),
      ),
    );
  }
}
