// Flutter imports
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/BaseClasses/base_entry.dart';
import 'package:omnirate/Database/database_helper.dart';
import 'package:omnirate/Database/model_show.dart';
import 'package:omnirate/Shared/utils.dart';

// ========== Game entry page ========== //

class ShowEntry extends EntryBase {
  const ShowEntry({super.key, required super.inEntry});

  @override
  ShowEntryState createState() => ShowEntryState();
}

class ShowEntryState extends EntryBaseState {
  // ===== Class Variables ===== //

  late Show currentShow;
  bool isLoaded = false;

  // ===== Class Initialization ===== //

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final show = await getShow(widget.inEntry.name);
      if (show != null) {
        setState(() {
          currentShow = show;
          isLoaded = true;
        });
      }
    });
  }

  // ===== Class Widgets ===== //

  // Show info
  Widget showInfo() {
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
            // Release Status
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Status: ',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                    ),
                  ),
                  TextSpan(
                    text: currentShow.releaseStatus,
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

            // First air date
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'First air date: ',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                    ),
                  ),
                  TextSpan(
                    text: currentShow.firstAir,
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

            // Last air date
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Last air date: ',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                    ),
                  ),
                  TextSpan(
                    text: currentShow.lastAir,
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

            // Number of episodes
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Total number of episodes: ',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                    ),
                  ),
                  TextSpan(
                    text: currentShow.episodesNum.toString(),
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

            // Number of seasons
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Number of seasons: ',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                    ),
                  ),
                  TextSpan(
                    text: (currentShow.seasonsEpisodeCounts.length).toString(),
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
                    text: currentShow.genres.join(', '),
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
            ExpandableText(label: 'Story: ', content: currentShow.overview),
          ],
        ),
      ),
    );
  }

  // Show info
  Widget seasonInfo(
    String inName,
    String inAirDate,
    String inEpisodeCount,
    String inOverview,
  ) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 40,
        title: Center(
          child: Text(
            inName,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),

      body: Card(
        color: Theme.of(context).colorScheme.surfaceContainer,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Air date
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Air date: ',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(text: inAirDate, style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),

              Divider(
                height: 16,
                thickness: 1,
                color: Theme.of(context).colorScheme.primary,
              ),

              // Number of episodes
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Number of episodes: ',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: inEpisodeCount,
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

              // Overview
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Overview: ',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(text: inOverview, style: TextStyle(fontSize: 16)),
                  ],
                ),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Available Seasons
  Widget showSeasons() {
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
            Text("Available Seasons:", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),

            SizedBox(
              height: 220,
              child: PageView.builder(
                itemCount: currentShow.seasonsNum,
                padEnds: false,
                controller: PageController(viewportFraction: 0.3),
                itemBuilder: (context, index) {
                  return GestureDetector(
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
                            image: DecorationImage(
                              image: NetworkImage(
                                currentShow.seasonsThumbnailsUrls[index],
                              ),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(12),
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
                                  currentShow.seasonsRatings[index].toString() == "0.0"
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
              Text("Loading show...", style: TextStyle(fontSize: 16)),
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

              // Padding
              const SizedBox(height: 8),

              // Game info
              showInfo(),

              // Padding
              const SizedBox(height: 8),

              // Seasons
              showSeasons(),
            ],
          ),
        ),
      ),
    );
  }
}
