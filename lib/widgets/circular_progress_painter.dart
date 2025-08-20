import 'package:flutter/material.dart';
import 'dart:math' as math;

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    this.strokeWidth = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            progressColor,
            progressColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      const startAngle = -math.pi / 2; // Start from top
      final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate is CircularProgressPainter &&
        oldDelegate.progress != progress;
  }
}

class CircularProgressWidget extends StatelessWidget {
  final double progress;
  final double size;

  const CircularProgressWidget({
    super.key,
    required this.progress,
    this.size = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isDark
              ? [
            const Color(0xFF1E293B),
            const Color(0xFF334155),
          ]
              : [
            Colors.white,
            const Color(0xFFF8FAFC),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomPaint(
        painter: CircularProgressPainter(
          progress: progress,
          backgroundColor: isDark
              ? const Color(0xFF475569).withOpacity(0.3)  // Darker gray for background
              : const Color(0xFFE2E8F0).withOpacity(0.5),  // Light gray for background
          progressColor: isDark
              ? const Color(0xFF10B981)  // Bright green for dark mode
              : const Color(0xFF6366F1),  // Indigo for light mode
          strokeWidth: 4.0,
        ),
        child: Center(
          child: Text(
            '${(progress * 100).round()}%',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark
                  ? const Color(0xFF10B981)  // Bright green text for dark mode
                  : const Color(0xFF6366F1),  // Indigo text for light mode
              fontSize: size > 40 ? 12 : 10,
            ),
          ),
        ),
      ),
    );
  }
}
