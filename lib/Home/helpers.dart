// ========== Futuristic Particles Painter ========== //

// Flutter imports
import 'dart:math';
import 'package:flutter/material.dart';

// New color constants for the theme
const Color kPrimaryBlue = Color(0xFF667EEA);
const Color kPrimaryPurple = Color(0xFF764BA2);

class ParticlesPainter extends CustomPainter {
  final List<Particle> particles;
  final Animation<double> animation;

  ParticlesPainter({required this.particles, required this.animation})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.8);

    for (var particle in particles) {
      // Animate particle position
      var progress = (animation.value + particle.offset) % 1.0;
      final position = Offset(
        particle.x * size.width,
        size.height - (progress * size.height),
      );
      // Fade out at the top
      paint.color = Colors.white.withValues(
        alpha: particle.opacity * (1 - progress),
      );
      canvas.drawCircle(position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlesPainter oldDelegate) => false;
}

class Particle {
  final double x;
  final double size;
  final double opacity;
  final double offset; // Stagger animation start
  Particle({
    required this.x,
    required this.size,
    required this.opacity,
    required this.offset,
  });
}

class FuturisticLoadingIndicator extends StatefulWidget {
  const FuturisticLoadingIndicator({super.key});

  @override
  State<FuturisticLoadingIndicator> createState() =>
      FuturisticLoadingIndicatorState();
}

class FuturisticLoadingIndicatorState extends State<FuturisticLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _textIndex = 0;
  final _loadingTexts = [
    '// ANALYZING MOOD VECTORS...',
    '// CROSS-REFERENCING UNIVERSE CATALOG...',
    '// CALIBRATING TASTE PROFILE...',
    '// SYNTHESIZING RECOMMENDATIONS...',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _startTextAnimation();
  }

  void _startTextAnimation() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted)
        setState(() => _textIndex = (_textIndex + 1) % _loadingTexts.length);
      return mounted;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder:
              (context, child) => CustomPaint(
                painter: LoadingPainter(_animation.value),
                size: const Size(150, 150),
              ),
        ),
        const SizedBox(height: 40),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder:
              (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
          child: Text(
            _loadingTexts[_textIndex],
            key: ValueKey<int>(_textIndex),
            style: const TextStyle(
              color: kPrimaryBlue,
              fontSize: 16,
              fontFamily: 'monospace',
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class LoadingPainter extends CustomPainter {
  final double animationValue;
  LoadingPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final glowPaint =
        Paint()
          ..color = kPrimaryBlue.withOpacity(
            0.1 + (0.2 * (sin(animationValue * pi * 2) + 1) / 2),
          )
          ..style = PaintingStyle.fill
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.5);
    canvas.drawCircle(center, radius, glowPaint);

    final arcPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
    double arcStart = animationValue * 2 * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.9),
      arcStart,
      pi * 0.8,
      false,
      arcPaint..color = kPrimaryBlue.withOpacity(0.8),
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.7),
      -arcStart * 1.5,
      pi * 1.2,
      false,
      arcPaint..color = kPrimaryPurple.withOpacity(0.6),
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.5),
      arcStart * 2,
      pi * 0.6,
      false,
      arcPaint..color = kPrimaryBlue.withOpacity(0.4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
