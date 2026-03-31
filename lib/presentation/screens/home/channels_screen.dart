import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:ui';

import '../../widgets/animated_gradient_background.dart';
import '../../widgets/bouncing_wrapper.dart';
import '../../../logic/channels_cubit.dart';
import '../../../data/models/channel.dart';
import '../../../core/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../player/player_screen.dart';

class ChannelsScreen extends StatefulWidget {
  const ChannelsScreen({super.key});

  @override
  State<ChannelsScreen> createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<ChannelsScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            l10n.tvBroadcasting,
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search),
            ),
          ],
        ),
        body: BlocBuilder<ChannelsCubit, ChannelsState>(
        builder: (context, state) {
          if (state is ChannelsLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
          }

          if (state is ChannelsLoaded) {
            final allChannels = state.channels;
            final channels = _selectedCategory == null 
                ? allChannels 
                : allChannels.where((c) => c.category == _selectedCategory).toList();
                
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
                        _buildCategoryChip(l10n.culture, 'Culture'),
                        const SizedBox(width: 8),
                        _buildCategoryChip(l10n.sport, 'Sports'),
                      ],
                    ),
                  ),
                ),
                // Grid of Channels
                Expanded(
                  child: channels.isEmpty 
                    ? Center(child: Text(l10n.noResults, style: GoogleFonts.cairo(color: AppTheme.textSecondary)))
                    : AnimationLimiter(
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1, 
                            childAspectRatio: 1.6, // Slightly wider for cinematic feel
                            mainAxisSpacing: 20,
                          ),
                          itemCount: channels.length,
                          itemBuilder: (context, index) {
                            final channel = channels[index];
                            return AnimationConfiguration.staggeredGrid(
                              position: index,
                              duration: const Duration(milliseconds: 600),
                              columnCount: 1,
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: GalleryChannelCard(channel: channel),
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
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? value) {
    final isSelected = _selectedCategory == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = value),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryGreen : Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppTheme.primaryGreen : Colors.white.withValues(alpha: 0.5), 
                width: 1.5,
              ),
            ),
            child: Text(
              label,
              style: GoogleFonts.cairo(
                color: isSelected ? Colors.white : AppTheme.textMain,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GalleryChannelCard extends StatelessWidget {
  final Channel channel;
  const GalleryChannelCard({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    
    return BouncingWrapper(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(channel: channel)));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: Colors.white.withValues(alpha: 0.3),
              border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Logo Background Layer (Maximum clarity as requested)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.85, // Highly visible
                    child: channel.logoUrl.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: channel.logoUrl,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            channel.logoUrl,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),

                // Minimal Blur & Tint Layer
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4), // Much lower blur for clarity
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.05), // Extremely light
                    ),
                  ),
                ),
                
                // Play Icon Overlay explicitly centered
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 48),
                  ),
                ),

                // Info Overlay (Glassmorphic) bottom section
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              ),
                              child: channel.logoUrl.startsWith('http')
                                  ? CachedNetworkImage(imageUrl: channel.logoUrl, fit: BoxFit.contain)
                                  : Image.asset(channel.logoUrl, fit: BoxFit.contain),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isAr ? channel.nameAr : channel.name,
                                    style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.w800, 
                                      fontSize: 16,
                                      color: AppTheme.textMain,
                                    ),
                                  ),
                                  Text(
                                    channel.slogan ?? l10n.live,
                                    style: GoogleFonts.cairo(
                                      color: AppTheme.textSecondary, 
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Glowing Live Indicator
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.mauritaniaRed.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppTheme.mauritaniaRed.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.mauritaniaRed,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    l10n.liveLabel,
                                    style: GoogleFonts.cairo(
                                      color: AppTheme.mauritaniaRed, 
                                      fontSize: 11, 
                                      fontWeight: FontWeight.w800
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
