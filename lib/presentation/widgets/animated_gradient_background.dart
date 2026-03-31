import 'package:flutter/material.dart';

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  const AnimatedGradientBackground({super.key, required this.child});

  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _color1;
  late Animation<Color?> _color2;
  late Animation<Color?> _color3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);

    _color1 = ColorTween(
      begin: const Color(0xFFF0FDF4),  // Very light green
      end: const Color(0xFFE0F2FE),    // Very light blue
    ).animate(_controller);

    _color2 = ColorTween(
      begin: const Color(0xFFFEF3C7),  // Very light amber/gold
      end: const Color(0xFFF3E8FF),    // Very light purple
    ).animate(_controller);

    _color3 = ColorTween(
      begin: const Color(0xFFFFFFFF),
      end: const Color(0xFFF8FAFC),    // Slate 50
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _color1.value ?? Colors.white,
                _color2.value ?? Colors.white,
                _color3.value ?? Colors.white,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
