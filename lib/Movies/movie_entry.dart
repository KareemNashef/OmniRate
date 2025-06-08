// ==================== Movie Entry Page ==================== //

// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/BasePages/base_entry_page.dart';
import 'package:omnirate/Database/database_helper.dart';
import 'package:omnirate/Database/model_movie.dart';
import 'package:omnirate/Shared/utils.dart';

// ========== Movie Entry Page Class ========== //

class MovieEntry extends EntryPageBase {
  const MovieEntry({super.key, required super.inEntry});

  @override
  MovieEntryState createState() => MovieEntryState();
}

class MovieEntryState extends EntryPageBaseState {
  // ===== Class Variables ===== //

  late Movie currentMovie;
  bool isLoaded = false;

  // ===== Lifecycle Methods ===== //

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final movie = await getMovie(widget.inEntry.id);
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
    return Column(
      children: [
        // Section header
        sectionHeader(context, 'Movie info', "Information about the movie."),

        // Movie info
        Container(
          decoration: containerDecoration(context),

          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              infoLine("Release Date: ", currentMovie.releaseStatus),
              divider(),
              infoLine("Genres: ", currentMovie.genres.join(', ')),
              divider(),

              // Story with Read More toggle
              ExpandableText(label: 'Story: ', content: currentMovie.overview),
            ],
          ),
        ),
      ],
    );
  }

  Widget budgetAndRevenue() {
    String formatMoney(dynamic amount) {
      if (amount == 'N/A' || amount == '0') return 'N/A';
      final numVal = num.tryParse(amount.toString()) ?? 0;
      if (numVal >= 1e9) return '\$${(numVal / 1e9).toStringAsFixed(1)}B';
      if (numVal >= 1e6) return '\$${(numVal / 1e6).toStringAsFixed(1)}M';
      if (numVal >= 1e3) return '\$${(numVal / 1e3).toStringAsFixed(1)}K';
      return '\$${numVal.toStringAsFixed(0)}';
    }

    // Data card
    Widget buildCard(String label, String time) {
      return Container(
        decoration: containerDecoration(context),
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            // Label
            Text(label, style: TextStyle(fontSize: 14)),

            // Padding
            SizedBox(height: 8),

            // Data
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
      );
    }

    return Column(
      children: [
        // Section header
        sectionHeader(
          context,
          'Budget and Revenue',
          "Information about the movie's budget and revenue.",
        ),

        // Cards
        Row(
          children: [
            Expanded(
              child: buildCard('Budget', formatMoney(currentMovie.budget)),
            ),
            SizedBox(width: 8),
            Expanded(
              child: buildCard('Revenue', formatMoney(currentMovie.revenue)),
            ),
          ],
        ),
      ],
    );
  }

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
    if (isLoaded == false) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: gradientBackground(context)),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: buttonDecoration(context),
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Loading Movie...",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Please wait a moment",
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: gradientBackground(context)),

        child: SingleChildScrollView(
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

                // Game info
                movieInfo(),

                // Padding
                const SizedBox(height: 8),

                // Budget and revenue
                budgetAndRevenue(),

                // Padding
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
