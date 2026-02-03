import 'dart:async';
import 'dart:math';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../data/models/channel.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/app_theme.dart';

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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          channelName,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.remove_red_eye, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  _formatViewCount(_viewCount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _buildBody(l10n),
    );
  }

  String _formatViewCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  Widget _buildBody(AppLocalizations? l10n) {
    if (_hasError) {
      return _buildErrorWidget(_errorMessage);
    }

    if (_isInitializing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.white,
            ),
            SizedBox(height: 16),
            Text(
              'جاري تحميل الفيديو...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_chewieController != null &&
        _videoPlayerController != null &&
        _videoPlayerController!.value.isInitialized) {
      return Chewie(controller: _chewieController!);
    }

    return _buildErrorWidget('فشل تهيئة المشغل');
  }
}
