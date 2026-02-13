import 'dart:async';
import 'dart:math';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import '../../../data/models/channel.dart';
import '../../../logic/channels_cubit.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/app_theme.dart';
import '../../../logic/favorites_cubit.dart';

class PlayerScreen extends StatefulWidget {
  final Channel channel;
  const PlayerScreen({super.key, required this.channel});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitializing = true;
  String? _errorMessage;
  bool _hasError = false;
  
  // Real-time view count simulation
  int _viewCount = 0;
  Timer? _viewTimer;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    
    // Simulate initial views (between 1000 and 5000)
    _viewCount = 1000 + Random().nextInt(4000);
    
    // Simulate real-time fluctuation
    _viewTimer = Timer.periodic(Duration(seconds: 3 + Random().nextInt(5)), (timer) {
      if (mounted) {
        setState(() {
          // Randomly add/remove 1-5 viewers
          int change = Random().nextBool() ? 1 : -1;
          _viewCount += change * (1 + Random().nextInt(5));
        });
      }
    });
  }

  Future<void> _initializePlayer() async {
    try {
      setState(() {
        _isInitializing = true;
        _hasError = false;
        _errorMessage = null;
      });

      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.channel.streamUrl),
      );

      // إضافة مستمع للأخطاء
      _videoPlayerController!.addListener(_videoPlayerListener);

      await _videoPlayerController!.initialize();

      if (!mounted) return;

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: 16 / 9,
        errorBuilder: (context, errorMessage) {
          return _buildErrorWidget(errorMessage);
        },
        // إعدادات إضافية لتحسين التجربة
        showControls: true,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
      );

      setState(() {
        _isInitializing = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isInitializing = false;
        _hasError = true;
        _errorMessage = _getErrorMessage(e);
      });
    }
  }

  void _videoPlayerListener() {
    if (_videoPlayerController == null) return;

    if (_videoPlayerController!.value.hasError) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = _videoPlayerController!.value.errorDescription ??
              'حدث خطأ أثناء تشغيل الفيديو';
        });
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('network') ||
        error.toString().contains('SocketException')) {
      return 'مشكلة في الاتصال بالإنترنت';
    } else if (error.toString().contains('format') ||
        error.toString().contains('codec')) {
      return 'تنسيق الفيديو غير مدعوم';
    } else if (error.toString().contains('timeout')) {
      return 'انتهت مهلة الاتصال';
    } else {
      return 'فشل تحميل الفيديو. يرجى المحاولة مرة أخرى';
    }
  }

  Widget _buildErrorWidget(String? message) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              message ?? l10n?.errorLoading ?? 'حدث خطأ',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _retryInitialization();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _retryInitialization() async {
    _videoPlayerController?.removeListener(_videoPlayerListener);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _videoPlayerController = null;
    _chewieController = null;
    await _initializePlayer();
  }

  String _formatViewCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  @override
  void dispose() {
    _viewTimer?.cancel();
    _videoPlayerController?.removeListener(_videoPlayerListener);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final channelName = Localizations.localeOf(context).languageCode == 'ar'
        ? widget.channel.nameAr
        : widget.channel.name;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(channelName),
        actions: [
          _buildLiveBadge(),
        ],
      ),
      body: _buildBody(l10n),
    );
  }

  Widget _buildLiveBadge() {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.mauritaniaRed,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.remove_red_eye_rounded, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            _formatViewCount(_viewCount),
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            l10n?.liveLabel ?? 'مباشر',
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AppLocalizations? l10n) {
    if (_hasError) {
      return _buildErrorWidget(_errorMessage);
    }

    return Column(
      children: [
        // 1. Video Player Section
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            color: Colors.black,
            child: _isInitializing
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : _chewieController != null &&
                        _videoPlayerController != null &&
                        _videoPlayerController!.value.isInitialized
                    ? Chewie(controller: _chewieController!)
                    : _buildErrorWidget(l10n?.errorLoading),
          ),
        ),
        // 2. Content Scroll Area
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Channel Title & Description
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${Localizations.localeOf(context).languageCode == 'ar' ? widget.channel.nameAr : widget.channel.name} HD',
                            style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'نشرة الأخبار الرئيسية', // This could be localized if we had data
                            style: GoogleFonts.cairo(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: widget.channel.logoUrl.startsWith('http')
                          ? CachedNetworkImage(imageUrl: widget.channel.logoUrl, fit: BoxFit.contain)
                          : Image.asset(widget.channel.logoUrl, fit: BoxFit.contain),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'تغطية شاملة لآخر التطورات المحلية، العلاقات الدولية، والمستجدات الاقتصادية في جميع أنحاء الجمهورية الإسلامية الموريتانية.',
                  style: GoogleFonts.cairo(color: AppTheme.textSecondary, fontSize: 13, height: 1.6),
                ),
                const SizedBox(height: 24),
                // Action Buttons (Favorite, Share, etc.)
                Row(
                  children: [
                    Expanded(
                      child: BlocBuilder<FavoritesCubit, FavoritesState>(
                        builder: (context, state) {
                          final isFav = state.favoriteIds.contains(widget.channel.id);
                          return _buildActionButton(
                            icon: isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            label: l10n?.favoritesTab ?? 'المفضلة',
                            color: isFav ? AppTheme.mauritaniaRed : AppTheme.primaryGreen,
                            bgColor: (isFav ? AppTheme.mauritaniaRed : AppTheme.primaryGreen).withValues(alpha: 0.1),
                            onTap: () {
                              context.read<FavoritesCubit>().toggleFavorite(widget.channel.id);
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.share_rounded,
                        label: l10n?.share ?? 'مشاركة',
                        color: AppTheme.accentGold,
                        bgColor: AppTheme.accentGold.withValues(alpha: 0.1),
                        onTap: () {
                          // Share logic
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // 3. Next Programs Schedule
                Text(
                  l10n?.nextPrograms ?? 'البرامج التالية',
                  style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildScheduleItem('20:30', 'مساًء', 'وثائقي: قلب الصحراء', 'ثقافة وتاريخ • 45 دقيقة'),
                const Divider(height: 32),
                _buildScheduleItem('21:15', 'مساًء', 'الملاعب الليلة', 'أبرز مباريات الدوري المحلي • 60 دقيقة'),
                const SizedBox(height: 32),
                // 4. Related Channels (Mocked)
                Text(
                  l10n?.relatedChannels ?? 'قنوات ذات صلة',
                  style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: BlocBuilder<ChannelsCubit, ChannelsState>(
                    builder: (context, state) {
                      if (state is ChannelsLoaded) {
                        final related = state.channels.where((c) => c.id != widget.channel.id).take(3).toList();
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: related.length,
                          itemBuilder: (context, index) {
                            final channel = related[index];
                            return Container(
                              width: 140,
                              margin: const EdgeInsets.only(left: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                image: DecorationImage(
                                  image: channel.logoUrl.startsWith('http')
                                      ? CachedNetworkImageProvider(channel.logoUrl)
                                      : AssetImage(channel.logoUrl) as ImageProvider,
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.3), BlendMode.darken),
                                ),
                              ),
                              alignment: Alignment.bottomCenter,
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                channel.nameAr,
                                style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            );
                          },
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required Color bgColor, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(String time, String period, String title, String subtitle) {
    return Row(
      children: [
        Column(
          children: [
            Text(time, style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(period, style: GoogleFonts.cairo(fontSize: 11, color: AppTheme.textSecondary)),
          ],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold)),
              Text(subtitle, style: GoogleFonts.cairo(fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ),
        ),
        Icon(Icons.notifications_none_rounded, color: AppTheme.textSecondary.withValues(alpha: 0.5)),
      ],
    );
  }
}
