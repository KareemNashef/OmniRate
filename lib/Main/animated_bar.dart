// Flutter imports
import 'package:flutter/material.dart';

// ========== Animated navigation bar ========== //

class AnimatedBottomBar extends StatefulWidget {
  // ===== Class Variables ===== //

  final List<AnimatedBottomBarItem> items;
  final int initialIndex;
  final Function(int) onTabSelected;
  final Duration animationDuration;
  final Curve animationCurve;
  final double iconSize;

  // ===== Constructor ===== //

  const AnimatedBottomBar({
    super.key,
    required this.items,
    this.initialIndex = 0,
    required this.onTabSelected,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutBack,
    this.iconSize = 24.0,
  });

  @override
  AnimatedBottomBarState createState() => AnimatedBottomBarState();
}

class AnimatedBottomBarState extends State<AnimatedBottomBar> {
  // ===== Class Variables ===== //

  late int _selectedIndex;

  // ===== Class Methods ===== //

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  // ===== Class Widgets ===== //

  Widget _buildTabItem(int index) {
    final isSelected = index == _selectedIndex;

    return SizedBox(
      height: 44.0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Icon animation
          AnimatedOpacity(
            duration: widget.animationDuration,
            curve: widget.animationCurve,
            opacity: isSelected ? 0.0 : 1.0,
            child: TweenAnimationBuilder<double>(
              duration: widget.animationDuration,
              curve: widget.animationCurve,
              tween: Tween<double>(
                begin: isSelected ? 0.0 : 1.0,
                end: isSelected ? -1.0 : 0.0,
              ),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, isSelected ? value * 10 : 0),
                  child: child,
                );
              },
              child: Icon(
                widget.items[index].icon,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: widget.iconSize,
              ),
            ),
          ),

          // Text animation
          AnimatedOpacity(
            duration: widget.animationDuration,
            curve: widget.animationCurve,
            opacity: isSelected ? 1.0 : 0.0,
            child: TweenAnimationBuilder<double>(
              duration: widget.animationDuration,
              curve: widget.animationCurve,
              tween: Tween<double>(
                begin: isSelected ? 1.0 : 0.0,
                end: isSelected ? 0.0 : 1.0,
              ),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, value * 10),
                  child: child,
                );
              },
              child: Text(
                widget.items[index].title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 56.0,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.1),
              blurRadius: 8.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = constraints.maxWidth / widget.items.length;
            final indicatorPosition =
                tabWidth * _selectedIndex + (tabWidth - 40) / 2;

            return Stack(
              children: [
                // Bottom indicator
                AnimatedPositioned(
                  duration: widget.animationDuration,
                  curve: widget.animationCurve,
                  bottom: 0,
                  left: indicatorPosition,
                  child: Container(
                    width: 40, // Fixed width of 40
                    height: 3, // Fixed height of 3
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                ),

                // Tabs
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(widget.items.length, (index) {
                    return Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedIndex = index;
                          });
                          widget.onTabSelected(index);
                        },
                        borderRadius: BorderRadius.circular(12.0),
                        child: _buildTabItem(index),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class AnimatedBottomBarItem {
  final IconData icon;
  final String title;

  const AnimatedBottomBarItem({required this.icon, required this.title});
}
