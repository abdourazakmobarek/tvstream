import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class GradientBackground extends StatefulWidget {
  final Widget child;
  const GradientBackground({super.key, required this.child});

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground> {
  List<Color> colorList = [
    AppTheme.midnightBlue,
    AppTheme.deepGreen,
    AppTheme.primaryGreen.withValues(alpha: 0.3),
    AppTheme.midnightBlue,
  ];

  List<Alignment> alignmentList = [
    Alignment.topLeft,
    Alignment.bottomRight,
    Alignment.topRight,
    Alignment.bottomLeft,
  ];

  int index = 0;
  Color bottomColor = AppTheme.midnightBlue;
  Color topColor = AppTheme.deepGreen;
  Alignment begin = Alignment.topLeft;
  Alignment end = Alignment.bottomRight;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          index = index + 1;
          bottomColor = colorList[index % colorList.length];
          topColor = colorList[(index + 1) % colorList.length];
          begin = alignmentList[index % alignmentList.length];
          end = alignmentList[(index + 2) % alignmentList.length];
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(seconds: 4),
          onEnd: () {},
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: begin,
              end: end,
              colors: [bottomColor, topColor],
            ),
          ),
        ),
        // Noise texture overlay for premium feel
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2), 
          ),
        ),
        widget.child,
      ],
    );
  }
}
