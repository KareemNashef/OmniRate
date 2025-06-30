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
  final bool commentPage;

  // ===== Constructor ===== //
  const AnimatedBackgroundCard({
    super.key,
    required this.inEntry,
    this.commentPage = false,
  });

  @override
  AnimatedBackgroundCardState createState() => AnimatedBackgroundCardState();
}

class AnimatedBackgroundCardState extends State<AnimatedBackgroundCard>
    with TickerProviderStateMixin {
  // ===== Class Variables ===== //

  // Controllers
  late AnimationController _backgroundController;
  late AnimationController _transitionController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _heightAnimation;
  late Animation<double> _fadeAnimation;

  // ===== Lifecycle Methods ===== //

  @override
  void initState() {
    super.initState();

    // Background animation controller (existing)
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );

    _backgroundController.repeat(reverse: true);

    // Transition animation controller (new)
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Height animation for container collapse/expand
    _heightAnimation = Tween<double>(
      begin: widget.commentPage ? 100.0 : 280.0,
      end: widget.commentPage ? 100.0 : 280.0,
    ).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // Fade animation for thumbnail and rating
    _fadeAnimation = Tween<double>(
      begin: widget.commentPage ? 0.0 : 1.0,
      end: widget.commentPage ? 0.0 : 1.0,
    ).animate(
      CurvedAnimation(parent: _transitionController, curve: Curves.easeInOut),
    );

    // Start in the correct state
    if (widget.commentPage) {
      _transitionController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedBackgroundCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animate when commentPage changes
    if (oldWidget.commentPage != widget.commentPage) {
      _animateTransition();
    }
  }

  void _animateTransition() {
    // Update animation end values based on new commentPage state
    _heightAnimation = Tween<double>(
      begin: _heightAnimation.value,
      end: widget.commentPage ? 100.0 : 280.0,
    ).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: _fadeAnimation.value,
      end: widget.commentPage ? 0.0 : 1.0,
    ).animate(
      CurvedAnimation(parent: _transitionController, curve: Curves.easeInOut),
    );

    // Reset and start the transition
    _transitionController.reset();
    _transitionController.forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  // ===== Class Widgets ===== //

  Widget entryMain() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _backgroundAnimation,
        _transitionController,
      ]),
      builder: (context, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          height: _heightAnimation.value,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Animated, zoomed background
                Positioned.fill(
                  child: Transform.translate(
                    offset: Offset(_backgroundAnimation.value * 50, 0),
                    child: Transform.scale(
                      scale: 1.3,
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
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
                      // Animated thumbnail
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SizeTransition(
                              sizeFactor: animation,
                              axis: Axis.horizontal,
                              child: child,
                            ),
                          );
                        },
                        child:
                            !widget.commentPage
                                ? Row(
                                  key: const ValueKey('thumbnail-row'),
                                  children: [
                                    SizedBox(
                                      width: 135,
                                      height: 240,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: buildImageFromUrl(
                                          widget.inEntry.thumbnailUrl,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                  ],
                                )
                                : const SizedBox.shrink(
                                  key: ValueKey('empty-thumbnail'),
                                ),
                      ),

                      // Content section
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              widget.inEntry.name,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: widget.commentPage ? 20 : 24,
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

                            // Animated spacing and rating
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SizeTransition(
                                    sizeFactor: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child:
                                  !widget.commentPage
                                      ? Column(
                                        key: const ValueKey('rating-section'),
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 16),
                                          // Enhanced rating badge
                                          ratingsIndicator(
                                            context,
                                            widget.inEntry.rating.toString(),
                                            opaque: true,
                                          ),
                                        ],
                                      )
                                      : const SizedBox.shrink(
                                        key: ValueKey('empty-rating'),
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
                    animation: _backgroundAnimation,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment(
                              -1.0 + _backgroundAnimation.value * 2,
                              -1.0,
                            ),
                            end: Alignment(
                              1.0 + _backgroundAnimation.value * 2,
                              1.0,
                            ),
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
