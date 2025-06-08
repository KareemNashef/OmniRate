// ==================== Animated Entry ==================== //

// Flutter imports
import 'dart:ui';
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/Database/model_entry.dart';
import 'package:omnirate/Shared/utils.dart';

// ========== Animated Entry Class ========== //

class AnimatedBackgroundCard extends StatefulWidget {
  // ===== Input Variables ===== //
  final MediaEntry inEntry;

  // ===== Constructor ===== //
  const AnimatedBackgroundCard({super.key, required this.inEntry});

  @override
  AnimatedBackgroundCardState createState() => AnimatedBackgroundCardState();
}

class AnimatedBackgroundCardState extends State<AnimatedBackgroundCard>
    with SingleTickerProviderStateMixin {
  // ===== Class Variables ===== //

  // Controllers
  late AnimationController _controller;
  late Animation<double> _animation;

  // ===== Lifecycle Methods ===== //

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ===== Class Widgets ===== //

  Widget entryMain() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Animated, zoomed background
              Positioned.fill(
                child: Transform.translate(
                  offset: Offset(_animation.value * 50, 0),
                  child: Transform.scale(
                    scale: 1.3,
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: buildImageFromUrl(widget.inEntry.artworkUrl),
                    ),
                  ),
                ),
              ),

              // Content layer
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Thumbnail
                    SizedBox(
                      width: 135,
                      height: 240,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: buildImageFromUrl(widget.inEntry.thumbnailUrl),
                      ),
                    ),

                    const SizedBox(width: 20),

                    // Content section
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            widget.inEntry.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.5,
                              height: 1.2,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Enhanced rating badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.amber.withValues(alpha: 0.3),
                                  Colors.orange.withValues(alpha: 0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: 22,
                                  color: Colors.amberAccent,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.3,
                                      ),
                                      offset: const Offset(0, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  double.tryParse(
                                        widget.inEntry.rating,
                                      )?.toStringAsFixed(1) ??
                                      'N/A',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    letterSpacing: 0.5,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.4,
                                        ),
                                        offset: const Offset(0, 1),
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Subtle shine effect overlay
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment(-1.0 + _animation.value * 2, -1.0),
                          end: Alignment(1.0 + _animation.value * 2, 1.0),
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.1),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    return entryMain();
  }
}
