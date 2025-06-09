// ==================== Games Main Page ==================== //

// Flutter imports
import 'package:flutter/material.dart';
import 'package:omnirate/API/igdb_api.dart';

// Local imports
import 'package:omnirate/BasePages/media_page.dart';
import 'package:omnirate/Database/model_game.dart';
import 'package:omnirate/Shared/utils.dart';

// ========== Games main page ========== //

class GamesMainPage extends MediaPageBase {
  const GamesMainPage({super.key});

  @override
  GamesMainPageState createState() => GamesMainPageState();
}

class GamesMainPageState extends MediaPageBaseState {
  // ===== Class variables ===== //

  // Games lists
  late Future<List<Game>> futureDiscover;
  late Future<List<List<Game>>> futureCombined;

  // ===== Lifecycle Methods ===== //

  @override
  void initState() {
    super.initState();
    futureDiscover = getDiscoverGames();
    futureCombined = getCombinedGames();
  }

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: gradientBackground(context)),

      child: SingleChildScrollView(
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
              SizedBox(height: 16),

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
              FutureBuilder<List<List<Game>>>(
                future: futureCombined,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionHeader(
                          context,
                          "Coming Soon",
                          "Just around the corner",
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
                    "Coming Soon",
                    "Just around the corner",
                    snapshot.data![0],
                  );
                },
              ),

              // Recently Released
              FutureBuilder<List<List<Game>>>(
                future: futureCombined,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionHeader(
                          context,
                          "Recently Released",
                          "Just dropped",
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
                    "Just dropped",
                    snapshot.data![1],
                  );
                },
              ),

              // Top Rated
              FutureBuilder<List<List<Game>>>(
                future: futureCombined,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionHeader(context, "Top Rated", "Must-play hits"),
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
                    "Top Rated",
                    "Must-play hits",
                    snapshot.data![2],
                  );
                },
              ),

              // Padding
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
