// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/Shared/settings_theme.dart';

// Settings page main
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

// State class for the settings page
class _SettingsPageState extends State<SettingsPage> {
  // ===== Class Variables =====

  // ===== Helper Methods =====

  // ===== Helper Widgets =====

  // Big title widget
  Widget bigTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Small title widget
  Widget smallTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  // Settings entry widget with icon
  Widget settingsEntry(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // Icon on the left
          Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),

          SizedBox(width: 16),

          // Column for title and description
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title with font size 18
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // Description with smaller font size
              SizedBox(height: 4), // Adds space between title and description
              // Wrap description in a Text widget with overflow handling
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 200,
                ), // Set max width for the description
                child: Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  softWrap: true, // Allow wrapping
                  overflow:
                      TextOverflow.ellipsis, // Truncate with ellipsis if needed
                  maxLines: 2, // Limit to two lines
                ),
              ),
            ],
          ),

          // Arrow icon on the right
          Spacer(),
          Icon(Icons.arrow_forward_ios, size: 24, color: Theme.of(context).colorScheme.primary),
        ],
      ),
    );
  }

  // List tile entry widget
  Widget listTileEntry(
    IconData icon,
    String title,
    String description,
    Widget page,
  ) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      title: settingsEntry(icon, title, description),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }

  //  ===== Build Method =====

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(8, 80, 8, 0),
        children: [
          // Settings title
          bigTitle("Settings"),

          // List entry - Account settings page
          listTileEntry(
            Icons.manage_accounts,
            "Account",
            "Change your account settings",
            Temp(),
          ),

          // List entry - Theme settings page
          listTileEntry(
            Icons.color_lens,
            "Theme",
            "Change the theme of the app",
            ThemeSettingsPage(),
          ),

          // List entry - 


        ],
      ),
    );
  }
}

class Temp extends StatelessWidget {
  const Temp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Coming Soon")),
      body: const Center(
        child: Text(
          "This page is under construction.",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}
