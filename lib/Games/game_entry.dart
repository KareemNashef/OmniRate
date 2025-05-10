// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/BaseClasses/base_entry.dart';
import 'package:omnirate/Shared/utils.dart';

// ========== Game entry page ========== //

class GameEntry extends EntryBase {
  const GameEntry({super.key});

  @override
  GameEntryState createState() => GameEntryState();
}

class GameEntryState extends EntryBaseState {
  // ===== Class Widgets ===== //

  // Game info
  Widget gameInfo(
    String inReleaseDate,
    String inDeveloper,
    String inGenres,
    String inOverview,
  ) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainer,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Release date
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Release date: ',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                    ),
                  ),
                  TextSpan(text: inReleaseDate, style: TextStyle(fontSize: 16)),
                ],
              ),
            ),

            Divider(
              height: 16,
              thickness: 1,
              color: Theme.of(context).colorScheme.primary,
            ),

            // Developer
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Developer: ',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                    ),
                  ),
                  TextSpan(text: inDeveloper, style: TextStyle(fontSize: 16)),
                ],
              ),
            ),

            Divider(
              height: 16,
              thickness: 1,
              color: Theme.of(context).colorScheme.primary,
            ),

            // Genres
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Genres: ',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                    ),
                  ),
                  TextSpan(text: inGenres, style: TextStyle(fontSize: 16)),
                ],
              ),
            ),

            Divider(
              height: 16,
              thickness: 1,
              color: Theme.of(context).colorScheme.primary,
            ),

            // Overview with Read More toggle
            ExpandableText(label: 'Overview: ', content: inOverview),
          ],
        ),
      ),
    );
  }

  Widget timeToBeat(String inHaste, String inNormal, String inComplete) {
    Widget buildCard(String label, String time) {
      return Expanded(
        child: Card(
          color: Theme.of(context).colorScheme.surfaceContainer,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Text(label, style: TextStyle(fontSize: 14)),
                SizedBox(height: 8),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Time to Beat',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            buildCard('Hastily', inHaste),
            SizedBox(width: 8),
            buildCard('Normally', inNormal),
            SizedBox(width: 8),
            buildCard('Completely', inComplete),
          ],
        ),
      ],
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 80, 8, 0),
          child: Column(
            children: [
              // Entry
              entryMain(
                "The Witcher 3: Wild Hunt",
                "assets/Debug/Games/1.webp",
                "9.4",
              ),

              // Padding
              const SizedBox(height: 8),

              // Add to list
              addToList(),

              // Padding
              const SizedBox(height: 8),

              // Time to beat
              timeToBeat("33 H", "73 H", "166 H"),

              // Padding
              const SizedBox(height: 8),

              // Game info
              gameInfo(
                "May 19, 2015",
                "CD PROJEKT RED",
                "Action, RPG",
                "The Witcher 3: Wild Hunt concludes the overview of the witcher Geralt of Rivia, the series' protagonist, whose overview to date has been covered in the previous installments. Geralt's new mission comes in dark times as the mysterious and otherworldly army known as the Wild Hunt invades the Northern Kingdoms, leaving only blood soaked earth and fiery ruin in its wake; and it seems the Witcher is the key to stopping their cataclysmic rampage.",
              ),

              // Padding
              const SizedBox(height: 8),

              // Related media
              relatedMedia(),
            ],
          ),
        ),
      ),
    );
  }
}
