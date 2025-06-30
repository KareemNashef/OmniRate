// flutter imports
import 'dart:async';
import 'package:flutter/material.dart';

class AnimatedListItem extends StatefulWidget {
  /// The child widget to animate.
  final Widget child;

  /// The index of the item in the list, used to calculate the stagger delay.
  final int index;

  /// The duration of the animation.
  final Duration animationDuration;

  /// The vertical offset for the slide animation.
  final double verticalOffset;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    this.animationDuration = const Duration(milliseconds: 400),
    this.verticalOffset = 50.0,
  });

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    // Staggered delay for each item
    final aLittleDelay = Duration(milliseconds: 200 * widget.index);

    // Create tweens
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, widget.verticalOffset / 1000), // Normalize offset
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    // Start animation after a short delay
    Timer(aLittleDelay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}