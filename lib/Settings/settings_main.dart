// ==================== Discover Page ==================== //

// Flutter imports
import 'package:flutter/material.dart';
import 'package:omnirate/Settings/settings_about.dart';

// Local imports
import 'package:omnirate/Settings/settings_theme.dart';
import 'package:omnirate/Settings/settings_account.dart';
import 'package:omnirate/Shared/utils.dart';

// ========== Settings Page Class ========== //

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // ===== Class Widgets ===== //

  Widget glassTile(
    IconData icon,
    String title,
    String subtitle, [
    VoidCallback? onTap,
  ]) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Padding
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),

        // Theme
        decoration: containerDecoration(context),

        // Content
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: gradientBackground(context)),

        child: ListView(
          padding: const EdgeInsets.fromLTRB(0, 100, 0, 16),
          children: [
            // Page title
            sectionHeader(context, "Settings", "Manage your preferences"),

            // Account settings
            glassTile(
              Icons.manage_accounts,
              "Account",
              "Change your account settings",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AccountSettingsPage()),
                );
              },
            ),

            // Theme settings
            glassTile(Icons.color_lens, "Theme", "Change app appearance", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ThemeSettingsPage()),
              );
            }),

            // About section
            glassTile(Icons.info, "About", "App version, terms & more", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AboutPage()),
              );
            }),
          ],
        ),
      ),
    );
  }
}
