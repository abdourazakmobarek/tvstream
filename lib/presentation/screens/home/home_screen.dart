import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tvstream/l10n/app_localizations.dart';

import '../../../logic/channels_cubit.dart';
import '../../../data/models/channel.dart';
import '../../../core/app_theme.dart';
import '../player/player_screen.dart';
import '../search/search_screen.dart';
import 'channels_screen.dart';
import '../../widgets/channel_card.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onRadioTab;
  const HomeScreen({super.key, this.onRadioTab});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChannelsCubit, ChannelsState>(
      builder: (context, state) {
        if (state is ChannelsLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen),
            ),
          );
        }

        if (state is ChannelsLoaded) {
          return Scaffold(
            backgroundColor: AppTheme.background,
            body: RefreshIndicator(
              onRefresh: () async {
                await context.read<ChannelsCubit>().refreshChannels();
              },
              color: AppTheme.primaryGreen,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // 1. Dashboard Header (Logo & Search)
                  const SliverToBoxAdapter(child: DashboardHeader()),

                  // 2. Action Shortcuts (TV & Radio)
                  SliverToBoxAdapter(child: ActionShortcuts(onRadioTap: onRadioTab)),

                  // 3. Featured Channels
                  SliverToBoxAdapter(
                    child: FeaturedChannels(channels: state.channels.take(5).toList()),
                  ),

                  // 4. Featured Radio Stations
                  SliverToBoxAdapter(
                    child: FeaturedRadioSection(
                      radioStations: state.radioChannels,
                      onViewAll: onRadioTab,
                    ),
                  ),

                  // Extra padding for bottom nav
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          );
        }

        return const Scaffold(body: Center(child: Text('حدث خطأ')));
      },
    );
  }
}

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.only(top: 56, left: 20, right: 20, bottom: 12),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFFF7FAF9), Colors.white],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.surface, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/TDM.png',
                  height: 82,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.appTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    color: AppTheme.primaryGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.surface, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.search, color: AppTheme.textSecondary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    l10n.searchPlaceholder,
                    style: GoogleFonts.cairo(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActionShortcuts extends StatelessWidget {
  final VoidCallback? onRadioTap;
  const ActionShortcuts({super.key, this.onRadioTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: _buildShortcut(
              context,
              icon: Icons.tv_rounded,
              label: l10n.tvBroadcasting,
              color: AppTheme.primaryGreen,
              bgColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ChannelsScreen()));
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildShortcut(
              context,
              icon: Icons.radio_rounded,
              label: l10n.radioBroadcasting,
              color: AppTheme.accentGold,
              bgColor: AppTheme.accentGold.withValues(alpha: 0.1),
              onTap: () {
                onRadioTap?.call();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcut(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.surface, width: 1.6),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.14),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeaturedChannels extends StatelessWidget {
  final List<Channel> channels;
  const FeaturedChannels({super.key, required this.channels});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: l10n.featuredChannels,
          actionText: l10n.viewAll,
          onActionTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ChannelsScreen()));
          },
        ),
        SizedBox(
          height: 188,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth > 600;
              final cardWidth = isTablet ? 186.0 : 146.0;
              
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: channels.length,
                itemBuilder: (context, index) {
                  final channel = channels[index];
                  return Container(
                    width: cardWidth,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: ChannelCard(channel: channel),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class FeaturedRadioSection extends StatelessWidget {
  final List<Channel> radioStations;
  final VoidCallback? onViewAll;

  const FeaturedRadioSection({
    super.key,
    required this.radioStations,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (radioStations.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: l10n.featuredRadio,
          actionText: l10n.viewAll,
          onActionTap: onViewAll,
        ),
        ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: radioStations.length > 4 ? 4 : radioStations.length,
          itemBuilder: (context, index) {
            final station = radioStations[index];
            final stationName = Localizations.localeOf(context).languageCode == 'ar'
                ? station.nameAr
                : station.name;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PlayerScreen(channel: station)),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.surface, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Radio logo
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: station.logoUrl.startsWith('http')
                            ? CachedNetworkImage(imageUrl: station.logoUrl, fit: BoxFit.contain)
                            : Image.asset(station.logoUrl, fit: BoxFit.contain),
                      ),
                      const SizedBox(width: 14),
                      // Station info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stationName,
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              station.slogan ?? l10n.radioSlogan,
                              style: GoogleFonts.cairo(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.mauritaniaRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          l10n.liveLabel,
                          style: GoogleFonts.cairo(
                            color: AppTheme.mauritaniaRed,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      // Play button
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: AppTheme.accentGold,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback? onActionTap;

  const _SectionHeader({
    required this.title,
    required this.actionText,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          InkWell(
            onTap: onActionTap,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Text(
                    actionText,
                    style: GoogleFonts.cairo(
                      color: AppTheme.primaryGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: AppTheme.primaryGreen,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}