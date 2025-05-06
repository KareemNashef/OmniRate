// Flutter imports
import 'package:flutter/material.dart';

// ========== Animated navigation bar ========== //

class AnimatedNavigationBar extends StatefulWidget {
  // ===== Class Variables ===== //
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  // ===== Constructor ===== //
  const AnimatedNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  State<AnimatedNavigationBar> createState() => _AnimatedNavigationBarState();
}

class _AnimatedNavigationBarState extends State<AnimatedNavigationBar> {
  // ===== Class Variables ===== //

  // List of labels and icons
  late final List<String> _labels = [
    'Games',
    'Shows',
    'Home',
    'Movies',
    'Assistant',
  ];
  late final List<IconData> _icons = [
    Icons.gamepad,
    Icons.tv,
    Icons.home,
    Icons.movie,
    Icons.assistant,
  ];

  // ===== Class Widgets ===== //

  // Builds a navigation item for the custom nav bar
  Widget _buildNavItem(int index, double itemWidth) {
    return SizedBox(
      // Ensure equal width for each nav item
      width: itemWidth,
      child: InkWell(
        onTap: () => widget.onDestinationSelected(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animate between icon and label
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.2),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child:
                  index == widget.selectedIndex
                      ? Text(
                        _labels[index], // Show label if selected
                        key: ValueKey('text-$index'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      : Icon(
                        _icons[index], // Show icon if not selected
                        key: ValueKey('icon-$index'),
                        size: 24,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
            ),
            // Padding
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    // Calculate available width considering margins
    final double availableWidth = MediaQuery.of(context).size.width - 32;
    final double itemWidth = availableWidth / _labels.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 60,
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: Stack(
            children: [
              // Nav items
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly, // Changed to spaceEvenly
                children: List.generate(_labels.length, (index) {
                  return _buildNavItem(index, itemWidth);
                }),
              ),
              // Animated indicator line
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                bottom: 0,
                left: itemWidth * widget.selectedIndex + (itemWidth - 40) / 2,
                child: Container(
                  width: 40,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
