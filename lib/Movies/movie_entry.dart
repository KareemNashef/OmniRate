// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/BaseClasses/base_entry.dart';
import 'package:omnirate/Database/model_movie.dart';
import 'package:omnirate/Shared/utils.dart';

// ========== Game entry page ========== //

class MovieEntry extends EntryBase {
  const MovieEntry({super.key, required super.inEntry});

  @override
  MovieEntryState createState() => MovieEntryState();
}

class MovieEntryState extends EntryBaseState {
  // ===== Class Widgets ===== //

  // Movie info
  Widget movieInfo() {
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
                    text: 'Release Date: ',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                    ),
                  ),
                  TextSpan(
                    text: (widget.inEntry as Movie).releaseStatus,
                    style: TextStyle(fontSize: 16),
                  ),
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
                  TextSpan(
                    text: (widget.inEntry as Movie).genres.join(', '),
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

            Divider(
              height: 16,
              thickness: 1,
              color: Theme.of(context).colorScheme.primary,
            ),

            // Story with Read More toggle
            ExpandableText(
              label: 'Story: ',
              content: (widget.inEntry as Movie).overview,
            ),
          ],
        ),
      ),
    );
  }

  // Budget and revenue
  Widget budgetAndRevenue() {
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

    return Row(
      children: [
        buildCard('Budget', (widget.inEntry as Movie).budget),
        SizedBox(width: 8),
        buildCard('Revenue', (widget.inEntry as Movie).revenue),
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
              entryMain(),

              // Padding
              const SizedBox(height: 8),

              // Add to list
              addToList(),

              // Padding
              const SizedBox(height: 8),

              // Budget and revenue || Removed for now TODO
              // budgetAndRevenue(),

              // Padding
              const SizedBox(height: 8),

              // Game info
              movieInfo(),
            ],
          ),
        ),
      ),
    );
  }
}
