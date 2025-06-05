// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/BaseClasses/base_entry.dart';
import 'package:omnirate/Shared/utils.dart';

// ========== Game entry page ========== //

class ShowEntry extends EntryBase {
  const ShowEntry({super.key, required super.inEntry});

  @override
  ShowEntryState createState() => ShowEntryState();
}

class ShowEntryState extends EntryBaseState {
  // ===== Class Widgets ===== //

  // Show info
  Widget showInfo(
    String inReleaseStatus,
    String inFirstAir,
    String inLastAir,
    String inEpisodesNum,
    String inSeasonsNum,
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
                    text: inReleaseStatus,
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
                  TextSpan(text: inFirstAir, style: TextStyle(fontSize: 16)),
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
                  TextSpan(text: inLastAir, style: TextStyle(fontSize: 16)),
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
                  TextSpan(text: inEpisodesNum, style: TextStyle(fontSize: 16)),
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
                  TextSpan(text: inSeasonsNum, style: TextStyle(fontSize: 16)),
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

            // Story with Read More toggle
            ExpandableText(label: 'Story: ', content: inOverview),
          ],
        ),
      ),
    );
  }

  // Show info
  Widget seasonInfo({
    String inName = "Season 3",
    String inAirDate = "2010-03-21",
    String inEpisodeCount = "13",
    String inOverview =
        "Walt continues to battle dueling identities: a desperate husband and father trying to provide for his family, and a newly appointed key player in the Albuquerque drug trade. As the danger around him escalates, Walt is now entrenched in the complex worlds of an angst-ridden family on the verge of dissolution, and the ruthless and unrelenting drug cartel.",
  }) {
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

  // Related Media
  Widget showSeasons(List<String> inPaths, List<String> inRatings) {
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
            Text("Available Seasons:", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),

            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => seasonInfo(),
                );
              },
              child: SizedBox(
                height: 220,
                child: PageView.builder(
                  itemCount: inPaths.length,
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
                            image: DecorationImage(
                              image: AssetImage(inPaths[index]),
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
                                  inRatings[index],
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
                    );
                  },
                ),
              ),
            ),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 80, 8, 0),
          child: Column(
            children: [
              // Entry
              // entryMain("Breaking Bad", "assets/Debug/Shows/9.webp", "8.9"),

              // Padding
              const SizedBox(height: 8),

              // Add to list
              addToList(),

              // Padding
              const SizedBox(height: 8),

              // Padding
              const SizedBox(height: 8),

              // Game info
              showInfo(
                "Ended",
                "2008-01-20",
                "2013-09-29",
                "62",
                "5",
                "Drama, Crime",
                "Walter White, a New Mexico chemistry teacher, is diagnosed with Stage III cancer and given a prognosis of only two years left to live. He becomes filled with a sense of fearlessness and an unrelenting desire to secure his family's financial future at any cost as he enters the dangerous world of drugs and crime.",
              ),

              // Padding
              const SizedBox(height: 8),

              // Seasons
              showSeasons(
                [
                  "assets/Debug/Shows/s1.webp",
                  "assets/Debug/Shows/s2.webp",
                  "assets/Debug/Shows/s3.webp",
                  "assets/Debug/Shows/s4.webp",
                  "assets/Debug/Shows/s5.webp",
                ],
                ["8.3", "8.4", "8.4", "8.6", "8.9"],
              ),

              // Related media
              relatedMedia(),
            ],
          ),
        ),
      ),
    );
  }
}
