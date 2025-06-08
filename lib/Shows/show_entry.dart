// ==================== Show Entry Page ==================== //

// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/BasePages/base_entry_page.dart';
import 'package:omnirate/Database/database_helper.dart';
import 'package:omnirate/Database/model_show.dart';
import 'package:omnirate/Shared/utils.dart';

// ========== Show Entry Page Class ========== //

class ShowEntry extends EntryPageBase {
  const ShowEntry({super.key, required super.inEntry});

  @override
  ShowEntryState createState() => ShowEntryState();
}

class ShowEntryState extends EntryPageBaseState {
  // ===== Class Variables ===== //

  late Show currentShow;
  bool isLoaded = false;

  // ===== Lifecycle Methods ===== //

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final show = await getShow(widget.inEntry.id);
      if (show != null) {
        setState(() {
          currentShow = show;
          isLoaded = true;
        });
      }
    });
  }

  // ===== Class Widgets ===== //

  Widget showInfo() {
    return Column(
      children: [
        // Section header
        sectionHeader(context, 'Show info', "Information about the show."),

        // Show info
        Container(
          decoration: containerDecoration(context),

          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              infoLine('Status: ', currentShow.releaseStatus),
              divider(),
              infoLine('First air date: ', currentShow.firstAir),
              divider(),
              infoLine('Last air date: ', currentShow.lastAir),
              divider(),
              infoLine(
                'Total number of episodes: ',
                currentShow.episodesNum.toString(),
              ),
              divider(),
              infoLine(
                'Number of seasons: ',
                (currentShow.seasonsEpisodeCounts.length).toString(),
              ),
              divider(),
              infoLine('Genres: ', currentShow.genres.join(', ')),
              divider(),

              // Story with Read More toggle
              ExpandableText(label: 'Story: ', content: currentShow.overview),
            ],
          ),
        ),
      ],
    );
  }

  Widget seasonInfo(
    String inName,
    String inAirDate,
    String inEpisodeCount,
    String inOverview,
  ) {
    return Container(
      // Theme
      decoration: BoxDecoration(
        gradient: gradientBackground(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),

      // Padding
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),

      // Content
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Padding
          const SizedBox(height: 8),

          // Section titles
          sectionHeader(context, inName, "Number of episodes: $inEpisodeCount"),

          // Padding
          const SizedBox(height: 8),

          Container(
            // Padding
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),

            decoration: containerDecoration(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Air date
                infoLine('Air date: ', inAirDate),
                divider(),

                // Overview
                RichText(
                  textAlign: TextAlign.justify,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.85),
                    ),
                    children: [
                      TextSpan(
                        text: 'Overview: ',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(
                        text: inOverview == '' ? 'N/A' : inOverview,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Padding
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget showSeasons() {
    return Column(
      children: [
        // Section header
        sectionHeader(context, "Available Seasons", "Seasons of the show."),

        // Seasons
        Container(
          decoration: containerDecoration(context),

          padding: const EdgeInsets.all(16),

          child: SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(), // Smooth momentum scrolling
              itemCount: currentShow.seasonsNum,
              itemBuilder: (context, index) {
                return Container(
                  width: 100,
                  margin: EdgeInsets.only(
                    left: index == 0 ? 0 : 8,
                    right: index == currentShow.seasonsNum - 1 ? 0 : 8,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder:
                            (context) => seasonInfo(
                              currentShow.seasonsNames[index],
                              currentShow.seasonsAirDates[index],
                              currentShow.seasonsEpisodeCounts[index]
                                  .toString(),
                              currentShow.seasonsOverviews[index],
                            ),
                      );
                    },
                    child: Column(
                      children: [
                        // Thumbnail
                        Container(
                          width: 90,
                          height: 160,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.1),
                                Colors.white.withValues(alpha: 0.05),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                                spreadRadius: -5,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: buildImageFromUrl(
                              currentShow.seasonsThumbnailsUrls[index],
                            ),
                          ),
                        ),

                        // Padding
                        SizedBox(height: 8),

                        // Title
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Season ${index + 1}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.star, size: 16, color: Colors.amber),
                                SizedBox(width: 4),
                                Text(
                                  currentShow.seasonsRatings[index]
                                              .toString() ==
                                          "0.0"
                                      ? "N/A"
                                      : currentShow.seasonsRatings[index]
                                          .toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
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
                  "Loading show...",
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
                showInfo(),

                // Padding
                const SizedBox(height: 8),

                // Seasons
                showSeasons(),

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
