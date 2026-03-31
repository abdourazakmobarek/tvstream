import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/channel.dart';
import '../screens/player/player_screen.dart';
import 'dart:ui';
import 'bouncing_wrapper.dart';

class ChannelCard extends StatelessWidget {
  final Channel channel;
  const ChannelCard({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Localizations.localeOf(context).languageCode == 'ar';
    
    return BouncingWrapper(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(channel: channel)));
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22.5), // Slightly less than 24 to account for border
              child: Stack(
                children: [
                  // Glassy Logo Background
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.85, // Maximum visibility
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
                  
                  // Blur Layer
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                      child: Container(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),

                  // Foreground Logo
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: channel.logoUrl.startsWith('http')
                          ? CachedNetworkImage(
                              imageUrl: channel.logoUrl,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => const Icon(Icons.tv, color: Colors.white24),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            )
                          : Image.asset(channel.logoUrl, fit: BoxFit.contain),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isRtl ? channel.nameAr : channel.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B), // Slate 800
            ),
          ),
        ],
      ),
    );
  }
}
