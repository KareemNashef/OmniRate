// Flutter imports

import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/BaseClasses/base_entry.dart';
import 'package:omnirate/Database/database_helper.dart';
import 'package:omnirate/Database/model_game.dart';
import 'package:omnirate/Shared/utils.dart';

// ========== Game entry page ========== //

class GameEntry extends EntryBase {
  const GameEntry({super.key, required super.inTitle});

  @override
  GameEntryState createState() => GameEntryState();
}

class GameEntryState extends EntryBaseState {
  // ===== Class variables ===== //
  late Future<Game?> futureGame;

  // ===== Class Initialization ===== //

  @override
  void initState() {
    super.initState();
    futureGame = getGame(widget.inTitle);
  }

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

  // Time to beat
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
            buildCard(
              'Hastily',
              inHaste == 'N/A'
                  ? 'N/A'
                  : (double.tryParse(inHaste) ?? 0) > 999
                  ? '999+ H'
                  : '$inHaste H',
            ),

            SizedBox(width: 8),
            buildCard(
              'Normally',
              inNormal == 'N/A'
                  ? 'N/A'
                  : (double.tryParse(inNormal) ?? 0) > 999
                  ? '999+ H'
                  : '$inNormal H',
            ),

            SizedBox(width: 8),
            buildCard(
              'Completely',
              inComplete == 'N/A'
                  ? 'N/A'
                  : (double.tryParse(inComplete) ?? 0) > 999
                  ? '999+ H'
                  : '$inComplete H',
            ),
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
    return FutureBuilder<Game?>(
      future: futureGame,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(strokeWidth: 6),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData) {
          return Text('No game found');
        }
        Game? currentGame = snapshot.data;

        return Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 80, 8, 0),
              child: Column(
                children: [
                  // Entry
                  entryMain(
                    currentGame?.name ?? 'Unknown',
                    currentGame?.thumbnailUrl ??
                        'https://www.igdb.com/assets/no_cover_show-ef1e36c00e101c2fb23d15bb80edd9667bbf604a12fc0267a66033afea320c65.png',
                    (currentGame?.rating ?? 0.0).toString(),
                    inArtwork: currentGame?.artworkUrl ?? 'N/A',
                  ),

                  // Padding
                  const SizedBox(height: 8),

                  // Add to list
                  addToList(),

                  // Padding
                  const SizedBox(height: 8),

                  // Time to beat
                  timeToBeat(
                    currentGame?.timeHaste ?? 'N/A',
                    currentGame?.timeNormal ?? 'N/A',
                    currentGame?.timeComplete ?? 'N/A',
                  ),

                  // Padding
                  const SizedBox(height: 8),

                  // Game info
                  gameInfo(
                    currentGame?.releaseDate ?? 'N/A',
                    currentGame?.developer ?? 'N/A',
                    currentGame?.genres.join(', ') ?? 'N/A',
                    currentGame?.overview ?? 'N/A',
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
      },
    );
  }
}
