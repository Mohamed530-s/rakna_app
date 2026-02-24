import 'dart:math' as math;

import 'package:flutter/material.dart';

class CyberpunkBackground extends StatefulWidget {
  final Widget? child;
  const CyberpunkBackground({super.key, this.child});

  @override
  State<CyberpunkBackground> createState() => _CyberpunkBackgroundState();
}

class _CyberpunkBackgroundState extends State<CyberpunkBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Container(
          color: isDark ? const Color(0xFF070707) : const Color(0xFFF0F2F5),
        ),
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _OrbPainter(
                  animationValue: _controller.value,
                  isDark: isDark,
                ),
                size: MediaQuery.of(context).size,
              );
            },
          ),
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _OrbPainter extends CustomPainter {
  final double animationValue;
  final bool isDark;

  _OrbPainter({required this.animationValue, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);

    final angle = animationValue * 2 * math.pi;

    if (isDark) {
      paint.color = const Color(0xFF00D97E).withValues(alpha: 0.10);
      canvas.drawCircle(
        Offset(
          size.width * 0.25 + math.sin(angle) * 60,
          size.height * 0.25 + math.cos(angle) * 40,
        ),
        180,
        paint,
      );

      paint.color = const Color(0xFF6B21A8).withValues(alpha: 0.08);
      canvas.drawCircle(
        Offset(
          size.width * 0.75 - math.cos(angle) * 50,
          size.height * 0.55 + math.sin(angle) * 35,
        ),
        200,
        paint,
      );

      paint.color = Colors.white.withValues(alpha: 0.03);
      canvas.drawCircle(
        Offset(
          size.width * 0.5 + math.sin(angle + 1) * 30,
          size.height * 0.80,
        ),
        140,
        paint,
      );
    } else {
      paint.color = const Color(0xFF059669).withValues(alpha: 0.06);
      canvas.drawCircle(
        Offset(
          size.width * 0.3 + math.sin(angle) * 40,
          size.height * 0.3 + math.cos(angle) * 30,
        ),
        160,
        paint,
      );

      paint.color = const Color(0xFF7C3AED).withValues(alpha: 0.04);
      canvas.drawCircle(
        Offset(
          size.width * 0.7 - math.cos(angle) * 40,
          size.height * 0.6 + math.sin(angle) * 25,
        ),
        180,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OrbPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.isDark != isDark;
  }
}
