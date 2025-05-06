// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/BaseClasses/base_entry.dart';

// ========== Game entry page ========== //

class GameEntry extends EntryBase {
  const GameEntry({super.key});

  @override
  GameEntryState createState() => GameEntryState();
}

class GameEntryState extends EntryBaseState {
  // ===== Class Widgets ===== //

  // Game info
  Widget gameInfo() {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainer,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity, // Set width to fill the available space
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Release date: X", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text("Developer: X", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text("Genres: X, Y", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text("Story: XXX", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  // Related Media
  Widget relatedMedia() {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainer,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity, // Set width to fill the available space
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Related Media:", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),

                    SizedBox(
          height: 200,
          child: PageView.builder(
            itemCount: 5,
            padEnds: false,
            controller: PageController(viewportFraction: 0.3),
            itemBuilder: (context, index) {
              return Column(
                children: [
                  // Thumbnail
                  Container(
                    width: 90,
                    height: 160,
                    decoration: BoxDecoration(
                      color:
                          Colors.primaries[DateTime.now()
                                  .millisecondsSinceEpoch %
                              Colors.primaries.length],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  // Padding
                  SizedBox(height: 8),

                  // Title
                  Text(
                    "Entry $index",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              );
            },
          ),
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 80, 8, 0),
        child: Column(
          children: [
            // Entry
            entryMain(),

            // Padding
            const SizedBox(height: 8),

            // Add to list
            addToList(),

            // Padding
            const SizedBox(height: 8),

            // Game info
            gameInfo(),

            // Padding
            const SizedBox(height: 8),

            // Related media
            relatedMedia(),
          ],
        ),
      ),
    );
  }
}
