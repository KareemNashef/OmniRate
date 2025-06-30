// ==================== Theme Settings Page ==================== //

// Flutter imports
import 'package:flutter/material.dart';
import 'package:omnirate/Shared/animated_list_item.dart';
import 'package:omnirate/Shared/utils.dart';
import 'package:provider/provider.dart';

// Local imports
import 'package:omnirate/Shared/providers.dart';

// ========== Theme Settings Page Class ========== //

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  // ===== Class Widgets ===== //

  Widget themeSelectionBar(BuildContext context) {
    Widget themeCard({
      required String assetPath,
      required bool isSelected,
      required VoidCallback onTap,
    }) {
      final double width = 120;
      final double height = 200;

      return SizedBox(
        width: width,
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: width,
                height: height,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color:
                      isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Image.asset(
                    assetPath,
                    width: width,
                    height: height,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onTap,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          themeCard(
            assetPath: 'assets/settings/LightMode.png',
            isSelected:
                context.watch<ThemeProvider>().themeMode == ThemeMode.light,
            onTap:
                () =>
                    context.read<ThemeProvider>().setThemeMode(ThemeMode.light),
          ),
          themeCard(
            assetPath: 'assets/settings/DarkMode.png',
            isSelected:
                context.watch<ThemeProvider>().themeMode == ThemeMode.dark,
            onTap:
                () =>
                    context.read<ThemeProvider>().setThemeMode(ThemeMode.dark),
          ),
          themeCard(
            assetPath: 'assets/settings/AutoMode.png',
            isSelected:
                context.watch<ThemeProvider>().themeMode == ThemeMode.system,
            onTap:
                () => context.read<ThemeProvider>().setThemeMode(
                  ThemeMode.system,
                ),
          ),
        ],
      ),
    );
  }

  Widget colorSelectionBar(BuildContext context) {
    List<Color> colors = [
      Color(0xFF2196f3),
      Color(0xFF6750a4),
      Color(0xFF009688),
      Color(0xFFffeb3b),
      Color(0xFFff9800),
      Color(0xFFe91e63),
      Color(0xFF4caf50),
      Color(0xFF3f51b5),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children:
              colors.map((color) {
                bool isSelected =
                    context.watch<ThemeProvider>().mainColor == color;
                return GestureDetector(
                  onTap:
                      () => context.read<ThemeProvider>().setMainColor(color),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border:
                          isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: color.withAlpha(128),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                              : [],
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    return Container(
      // Background
      decoration: BoxDecoration(gradient: gradientBackground(context)),

      // Foreground
      child: Scaffold(
        backgroundColor: Colors.transparent,

        // Body
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 100, bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedListItem(
                index: 1,
                child: Column(
                  children: [
                    sectionHeader(
                      context,
                      "Theme Mode",
                      "Choose how the app looks",
                    ),
                    const SizedBox(height: 12),
                    themeSelectionBar(context),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              AnimatedListItem(
                index: 2,
                child: Column(
                  children: [
                    sectionHeader(
                      context,
                      "Accent Color",
                      "Pick a color you like",
                    ),
                    const SizedBox(height: 12),
                    colorSelectionBar(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
