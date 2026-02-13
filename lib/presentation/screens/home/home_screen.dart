import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tvstream/l10n/app_localizations.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../logic/channels_cubit.dart';
import '../../../data/models/channel.dart';
import '../../../data/models/news_article.dart';
import '../../../data/services/news_service.dart';
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

                  // 4. Latest News
                  const SliverToBoxAdapter(child: NewsSection()),

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
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 20),
      child: Column(
        children: [
          // TDM Logo
          Image.asset(
            'assets/images/TDM.png',
            height: 80,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.appTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              color: AppTheme.primaryGreen,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          // Search Bar
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                   const Icon(Icons.search, color: AppTheme.textSecondary, size: 20),
                   const SizedBox(width: 12),
                   Text(
                     l10n.searchPlaceholder,
                     style: GoogleFonts.cairo(
                       color: AppTheme.textSecondary,
                       fontSize: 14,
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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.surface, width: 2),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 16,
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.featuredChannels,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ChannelsScreen()));
                },
                child: Text(
                  l10n.viewAll,
                  style: GoogleFonts.cairo(
                    color: AppTheme.primaryGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth > 600;
              final cardWidth = isTablet ? 180.0 : 140.0;
              
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

class NewsSection extends StatefulWidget {
  const NewsSection({super.key});

  @override
  State<NewsSection> createState() => _NewsSectionState();
}

class _NewsSectionState extends State<NewsSection> {
  final NewsService _newsService = NewsService();
  late Future<List<NewsArticle>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = _newsService.fetchLatestNews();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.latestNews,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                l10n.more,
                style: GoogleFonts.cairo(
                  color: AppTheme.primaryGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        FutureBuilder<List<NewsArticle>>(
          future: _newsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(color: AppTheme.primaryGreen),
                ),
              );
            }

            // Fallback to mock data if error or empty, but let's try to show error or empty state
            // For now, if empty, we might show nothing or a message.
            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  l10n.errorLoading,
                  style: GoogleFonts.cairo(color: Colors.grey),
                ),
              );
            }

            final newsList = snapshot.data!;

            return LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth > 600;
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet ? 2 : 1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: isTablet ? 3.5 : 3.0,
                  ),
                  itemCount: newsList.length > 4 ? 4 : newsList.length,
                  itemBuilder: (context, index) {
                    final article = newsList[index];
                    final isUrgent = index == 0;
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              image: const DecorationImage(
                                image: AssetImage('assets/images/TDM.png'), 
                                fit: BoxFit.contain, 
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (isUrgent ? AppTheme.mauritaniaRed : AppTheme.primaryGreen).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    l10n.news, // Use generic label for now
                                    style: GoogleFonts.cairo(
                                      color: isUrgent ? AppTheme.mauritaniaRed : AppTheme.primaryGreen,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  article.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.mauritanianRadio, // Placeholder for source/time
                                  style: GoogleFonts.cairo(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}