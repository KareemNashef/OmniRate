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

class LoadingIndicator extends StatefulWidget {
  const LoadingIndicator({super.key});

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _textIndex = 0;
  final _loadingTexts = [
    'Analyzing preferences...',
    'Finding matches...',
    'Preparing results...',
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
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        setState(() => _textIndex = (_textIndex + 1) % _loadingTexts.length);
      }
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
        const SizedBox(height: 200),

        AnimatedBuilder(
          animation: _animation,
          builder:
              (context, child) => CustomPaint(
                painter: LoadingPainter(_animation.value),
                size: const Size(120, 120),
              ),
        ),

        const SizedBox(height: 32),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder:
              (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
          child: Text(
            _loadingTexts[_textIndex],
            key: ValueKey<int>(_textIndex),
            style: TextStyle(
              color: kPrimaryBlue,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(height: 200),
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

    // Subtle background circle
    final bgPaint =
        Paint()
          ..color = const Color(0xFF3B82F6).withValues(alpha: 0.1)
          ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Main rotating arcs
    final arcPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.round;

    double rotation = animationValue * 2 * pi;

    // Outer arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.85),
      rotation,
      pi * 1.2,
      false,
      arcPaint..color = const Color(0xFF3B82F6).withValues(alpha: 0.8),
    );

    // Inner arc (counter-rotating)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.65),
      -rotation * 0.7,
      pi * 0.8,
      false,
      arcPaint..color = const Color(0xFF6366F1).withValues(alpha: 0.6),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
