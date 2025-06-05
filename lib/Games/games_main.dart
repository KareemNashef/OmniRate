// Flutter imports
import 'package:flutter/material.dart';
import 'package:omnirate/API/igdb_api.dart';

// Local imports
import 'package:omnirate/BaseClasses/base_main.dart';
import 'package:omnirate/Database/model_game.dart';

// ========== Games main page ========== //

class GamesMainPage extends MainPageBase {
  const GamesMainPage({super.key});

  @override
  GamesMainPageState createState() => GamesMainPageState();
}

class GamesMainPageState extends MainPageBaseState {
  // ===== Class variables ===== //

  late Future<List<Game>> futureDiscover;
  late Future<List<Game>> futureComingSoon;
  late Future<List<Game>> futureRecentlyReleased;
  late Future<List<Game>> futureTopRated;

  // ===== Class Initialization ===== //

  @override
  void initState() {
    super.initState();
    futureDiscover = getDiscoverGames();
    futureComingSoon = getComingSoonGames();
    futureRecentlyReleased = getRecentlyReleasedGames();
    futureTopRated = getTopRatedGames();
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
            // Padding
            SizedBox(height: 40),

            // Search Bar
            searchBar("Games"),

            // Padding
            SizedBox(height: 20),

            // Main Carousel
            FutureBuilder<List<Game>>(
              future: futureDiscover,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox(
                    height: 290,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                return mainCarousel("Games", snapshot.data!);
              },
            ),

            // Padding
            const SizedBox(height: 16),

            // Coming Soon
            FutureBuilder<List<Game>>(
              future: futureComingSoon,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "Coming Soon",
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
                return blankCarousel("Games", "Coming Soon", snapshot.data!);
              },
            ),

            // Recently Released
            FutureBuilder<List<Game>>(
              future: futureRecentlyReleased,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "Recently Released",
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
                return blankCarousel(
                  "Games",
                  "Recently Released",
                  snapshot.data!,
                );
              },
            ),

            // Top Rated
            FutureBuilder<List<Game>>(
              future: futureTopRated,
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
                return blankCarousel("Games", "Top Rated", snapshot.data!);
              },
            ),

            SizedBox(height: 64),
          ],
        ),
      ),
    );
  }
}
