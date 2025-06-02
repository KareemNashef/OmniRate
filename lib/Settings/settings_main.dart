// Flutter imports
import 'package:flutter/material.dart';
import 'package:omnirate/Movies/movie_entry.dart';
import 'package:flutter/services.dart';

// Local imports
import 'package:omnirate/Settings/settings_theme.dart';

import 'package:omnirate/Games/game_entry.dart';
import 'package:omnirate/Shows/show_entry.dart';
import 'package:omnirate/Main/welcome_page.dart';

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
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),

          Spacer(),

          // Easter egg
          StatefulBuilder(
            builder: (context, setState) {
              final controller = AnimationController(
                vsync: Scaffold.of(context),
                duration: Duration(milliseconds: 600),
              );
              final animation = Tween(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(parent: controller, curve: Curves.easeInOut),
              );

              return GestureDetector(
                onTap: () async {
                  controller.forward(from: 0);
                  final lines = await rootBundle.loadString(
                    'assets/settings/egg.txt',
                  );
                  if (!context.mounted) return;

                  final jokes = lines.split('\n')
                    ..removeWhere((l) => l.trim().isEmpty);
                  final joke = (jokes..shuffle()).first;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(joke),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 4),
                    ),
                  );
                },
                child: RotationTransition(
                  turns: animation,
                  child: Image.asset('assets/settings/egg.png', height: 80),
                ),
              );
            },
          ),
          SizedBox(width: 16),
        ],
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
          Icon(
            Icons.arrow_forward_ios,
            size: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
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

          // List entry - Debug 1
          listTileEntry(Icons.info, "Debug", "stuff", GameEntry()),

          // List entry - Debug 2
          listTileEntry(Icons.info, "Debug 2", "stuff", MovieEntry()),

          // List entry - Debug 3
          listTileEntry(Icons.info, "Debug 3", "stuff", ShowEntry()),

          // List entry - Debug 7
          listTileEntry(Icons.info, "Debug 7", "stuff", WelcomePage()),
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
