// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/BaseClasses/base_entry.dart';
import 'package:omnirate/Database/database_helper.dart';
import 'package:omnirate/Database/model_movie.dart';
import 'package:omnirate/Shared/utils.dart';

// ========== Game entry page ========== //

class MovieEntry extends EntryBase {
  const MovieEntry({super.key, required super.inEntry});

  @override
  MovieEntryState createState() => MovieEntryState();
}

class MovieEntryState extends EntryBaseState {
  // ===== Class Variables ===== //

  late Movie currentMovie;
  bool isLoaded = false;

  // ===== Class Initialization ===== //

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final movie = await getMovie(widget.inEntry.name);
      if (movie != null) {
        setState(() {
          currentMovie = movie;
          isLoaded = true;
        });
      }
    });
  }

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
                    text: currentMovie.releaseStatus,
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
                    text: currentMovie.genres.join(', '),
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
            ExpandableText(label: 'Story: ', content: currentMovie.overview),
          ],
        ),
      ),
    );
  }

  // Budget and revenue
  Widget budgetAndRevenue() {
String formatMoney(dynamic amount) {
  if (amount == 'N/A' || amount == '0') return 'N/A';
  final numVal = num.tryParse(amount.toString()) ?? 0;
  if (numVal >= 1e9) return '\$${(numVal / 1e9).toStringAsFixed(1)}B';
  if (numVal >= 1e6) return '\$${(numVal / 1e6).toStringAsFixed(1)}M';
  if (numVal >= 1e3) return '\$${(numVal / 1e3).toStringAsFixed(1)}K';
  return '\$${numVal.toStringAsFixed(0)}';
}

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
        buildCard('Budget', formatMoney(currentMovie.budget)),
        SizedBox(width: 8),
        buildCard('Revenue', formatMoney(currentMovie.revenue)),
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
    if (!isLoaded) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Loading movie...", style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    }

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
              budgetAndRevenue(),

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
