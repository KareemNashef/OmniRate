// ==================== Discover Page ==================== //

// Flutter imports
import 'package:flutter/material.dart';
import 'package:omnirate/Settings/settings_about.dart';

// Local imports
import 'package:omnirate/Settings/settings_theme.dart';
import 'package:omnirate/Settings/settings_account.dart';
import 'package:omnirate/Shared/utils.dart';
import 'package:omnirate/shared/animated_list_item.dart';

// A simple data class to hold tile information
class SettingsTileData {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  SettingsTileData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

// ========== Settings Page Class ========== //

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // ===== Class Widgets ===== //

  Widget glassTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
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
                    ).colorScheme.onSurface.withAlpha(180),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
          ),
        ],
      ),
    );
  }

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    
    final List<SettingsTileData> settingsItems = [

      // Account Settings
      SettingsTileData(
        icon: Icons.manage_accounts,
        title: "Account",
        subtitle: "Change your account settings",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AccountSettingsPage()),
          );
        },
      ),

      // Theme Settings
      SettingsTileData(
        icon: Icons.color_lens,
        title: "Theme",
        subtitle: "Change app appearance",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ThemeSettingsPage()),
          );
        },
      ),

      // About Section
      SettingsTileData(
        icon: Icons.info,
        title: "About",
        subtitle: "App version, terms & more",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AboutPage()),
          );
        },
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: gradientBackground(context)),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(0, 100, 0, 16),
          itemCount: settingsItems.length + 1,
          itemBuilder: (context, index) {

            // Section header
            if (index == 0) {
              return AnimatedListItem(
                index: 0,
                child: sectionHeader(
                  context,
                  "Settings",
                  "Manage your preferences",
                ),
              );
            }

            // Adjust index for the list of items
            final itemIndex = index - 1;
            final itemData = settingsItems[itemIndex];

            // Wrap each tile with our new AnimatedListItem widget
            return AnimatedListItem(
              index: index,
              child: GestureDetector(
                onTap: itemData.onTap,
                child: glassTile(
                  context,
                  itemData.icon,
                  itemData.title,
                  itemData.subtitle,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
