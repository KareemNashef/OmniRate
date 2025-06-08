// ==================== Theme Settings Page ==================== //

// Flutter imports
import 'package:flutter/material.dart';
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

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            width: 3,
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Container(
                width: width,
                height: height,
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
              ),
              Image.asset(
                assetPath,
                width: width,
                height: height,
                fit: BoxFit.cover,
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
      Color(0xFFEF5350),
      Color(0xFF66BB6A),
      Color(0xFF42A5F5),
      Color(0xFFFFEB3B),
      Color(0xFFAB47BC),
      Color(0xFFFF7043),
      Color(0xFF26C6DA),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children:
            colors.map((color) {
              bool isSelected =
                  context.watch<ThemeProvider>().mainColor == color;
              return GestureDetector(
                onTap: () => context.read<ThemeProvider>().setMainColor(color),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
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
              sectionHeader(
                context,
                "Theme Mode",
                "Choose how the app looks",
              ),
              const SizedBox(height: 12),
              themeSelectionBar(context),
              const SizedBox(height: 32),
              sectionHeader(context, "Accent Color", "Pick a color you like"),
              const SizedBox(height: 12),
              colorSelectionBar(context),
            ],
          ),
        ),
      ),
    );
  }
}
