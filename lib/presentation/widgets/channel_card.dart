import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/channel.dart';
import '../../core/app_theme.dart';
import '../screens/player/player_screen.dart';

class ChannelCard extends StatelessWidget {
  final Channel channel;
  const ChannelCard({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(channel: channel)));
      },
      borderRadius: BorderRadius.circular(24),
      child: Column(
        children: [
          Container(
            height: 130,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
            ),
            child: channel.logoUrl.startsWith('http')
                ? CachedNetworkImage(imageUrl: channel.logoUrl, fit: BoxFit.contain)
                : Image.asset(channel.logoUrl, fit: BoxFit.contain),
          ),
          const SizedBox(height: 8),
          Text(
            Localizations.localeOf(context).languageCode == 'ar' ? channel.nameAr : channel.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
