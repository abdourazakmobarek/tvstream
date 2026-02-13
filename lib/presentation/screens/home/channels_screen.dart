import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../logic/channels_cubit.dart';
import '../../../data/models/channel.dart';
import '../../../core/app_theme.dart';
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
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'القنوات التلفزيونية',
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
            final channels = state.channels;
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
                        _buildCategoryChip('الكل', null),
                        const SizedBox(width: 8),
                        _buildCategoryChip('أخبار', 'News'),
                        const SizedBox(width: 8),
                        _buildCategoryChip('ثقافة', 'Culture'),
                        const SizedBox(width: 8),
                        _buildCategoryChip('رياضة', 'Sports'),
                      ],
                    ),
                  ),
                ),
                // Grid of Channels
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1, // Layout from stitch/tv_channels_gallery/screen.png shows large items
                      childAspectRatio: 1.5,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: channels.length,
                    itemBuilder: (context, index) {
                      final channel = channels[index];
                      return GalleryChannelCard(channel: channel);
                    },
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text('فشل تحميل القنوات'));
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

class GalleryChannelCard extends StatelessWidget {
  final Channel channel;
  const GalleryChannelCard({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(channel: channel)));
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.grey.withValues(alpha: 0.1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Thumbnail (Mocked for now since channel model doesn't have it, usually same as logo or a screenshot)
            Positioned.fill(
              child: Container(
                color: Colors.grey.withValues(alpha: 0.2),
                child: Center(
                  child: Icon(Icons.play_circle_filled, color: Colors.white.withValues(alpha: 0.5), size: 64),
                ),
              ),
            ),
            // Info Overlay
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: channel.logoUrl.startsWith('http')
                          ? CachedNetworkImage(imageUrl: channel.logoUrl, fit: BoxFit.contain)
                          : Image.asset(channel.logoUrl, fit: BoxFit.contain),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            channel.nameAr,
                            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Text(
                            'مباشر الآن',
                            style: GoogleFonts.cairo(color: AppTheme.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.mauritaniaRed,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'مباشر',
                        style: GoogleFonts.cairo(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
