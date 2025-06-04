// Flutter imports
import 'package:flutter/material.dart';
import 'package:omnirate/API/igdb_api.dart';

// Local imports
import 'package:omnirate/BaseClasses/base_main.dart';
import 'package:omnirate/Database/database_helper.dart';

// ========== Games main page ========== //

class GamesMainPage extends MainPageBase {
  const GamesMainPage({super.key});

  @override
  GamesMainPageState createState() => GamesMainPageState();
}

class GamesMainPageState extends MainPageBaseState {
  // ===== Class variables ===== //

  late Future<Map<String, String>> futurePopular;
  late Future<Map<String, String>> futureUpcoming;
  late Future<Map<String, String>> futureLatest;
  late Future<Map<String, String>> futureTop;

  // ===== Class Initialization ===== //

  @override
  void initState() {
    super.initState();
    futurePopular = getPopularGames();
    futureUpcoming = getUpcomingGames();
    futureLatest = getLatestGames();
    futureTop = getTopGames();
  }

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            searchBar("Games"),
            SizedBox(height: 20),
            FutureBuilder<Map<String, String>>(
              future: futurePopular,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox(
                    height: 290,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final names = snapshot.data!.keys.toList();
                final paths = snapshot.data!.values.toList();

                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: Future.wait(
                    names.map((name) async {
                      final game = await getGame(name);
                      return {
                        'artwork': game?.artworkUrl ?? '',
                        'rating': game?.rating ?? 0.0,
                      };
                    }),
                  ),
                  builder: (context, artRatingSnapshot) {
                    if (!artRatingSnapshot.hasData) {
                      return SizedBox(
                        height: 290,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final artworks =
                        artRatingSnapshot.data!
                            .map((e) => e['artwork'] as String)
                            .toList();
                    final ratings =
                        artRatingSnapshot.data!
                            .map((e) => (e['rating'] ?? 0.0).toString())
                            .toList();

                    return mainCarousel(
                      "Games",
                      paths,
                      names,
                      inArtworks: artworks,
                      inRatings: ratings,
                    );
                  },
                );
              },
            ),

            // Upcoming Releases
            FutureBuilder<Map<String, String>>(
              future: futureUpcoming,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "Upcoming Releases",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      SizedBox(
                        height: 230,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  );
                }
                final names = snapshot.data!.keys.toList();
                final paths = snapshot.data!.values.toList();
                return blankCarousel(
                  "Games",
                  "Upcoming Releases",
                  paths,
                  names,
                );
              },
            ),

            // Latest Games
            FutureBuilder<Map<String, String>>(
              future: futureLatest,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "Latest Games",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      SizedBox(
                        height: 230,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  );
                }
                final names = snapshot.data!.keys.toList();
                final paths = snapshot.data!.values.toList();
                return blankCarousel("Games", "Latest Games", paths, names);
              },
            ),

            // Top Rated
            FutureBuilder<Map<String, String>>(
              future: futureTop,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "Top Rated",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      SizedBox(
                        height: 230,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  );
                }
                final names = snapshot.data!.keys.toList();
                final paths = snapshot.data!.values.toList();
                return blankCarousel("Games", "Top Rated", paths, names);
              },
            ),

            SizedBox(height: 64),
          ],
        ),
      ),
    );
  }
}
