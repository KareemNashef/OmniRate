// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/BaseClasses/base_main.dart';
import 'package:omnirate/Database/model_show.dart';
import 'package:omnirate/API/tmdb_api.dart';

// ========== Shows main page ========== //

class ShowsMainPage extends MainPageBase {
  const ShowsMainPage({super.key});

  @override
  ShowsMainPageState createState() => ShowsMainPageState();
}

class ShowsMainPageState extends MainPageBaseState {
  // ===== Class variables ===== //

  late Future<List<Show>> futurePopular;
  late Future<List<Show>> futureAiringToday;
  late Future<List<Show>> futureOnTheAir;
  late Future<List<Show>> futureTopRated;

  // ===== Class Initialization ===== //

  @override
  void initState() {
    super.initState();
    futurePopular = getPopularShows();
    futureAiringToday = getAiringTodayShows();
    futureOnTheAir = getOnTheAirShows();
    futureTopRated = getTopRatedShows();
  }

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 12,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Padding
            SizedBox(height: 40),

            // Search Bar
            searchBar("Shows"),

            // Main Carousel
            FutureBuilder<List<Show>>(
              future: futurePopular,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox(
                    height: 290,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                return mainCarousel("Shows", snapshot.data!);
              },
            ),

            // Airing Today
            FutureBuilder<List<Show>>(
              future: futureAiringToday,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "Airing Today",
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
                return blankCarousel("Shows", "Airing Today", snapshot.data!);
              },
            ),

            // On The Air
            FutureBuilder<List<Show>>(
              future: futureOnTheAir,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "On The Air",
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
                return blankCarousel("Shows", "On The Air", snapshot.data!);
              },
            ),

            // Top Rated
            FutureBuilder<List<Show>>(
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
                return blankCarousel("Shows", "Top Rated", snapshot.data!);
              },
            ),

            // Padding
            SizedBox(height: 64),
          ],
        ),
      ),
    );
  }
}
