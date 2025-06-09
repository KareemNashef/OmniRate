// ==================== Shows Main Page ==================== //

// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/BasePages/media_page.dart';
import 'package:omnirate/Database/model_show.dart';
import 'package:omnirate/API/tmdb_api.dart';
import 'package:omnirate/Shared/utils.dart';

// ========== Shows Main Page Class ========== //

class ShowsMainPage extends MediaPageBase {
  const ShowsMainPage({super.key});

  @override
  ShowsMainPageState createState() => ShowsMainPageState();
}

class ShowsMainPageState extends MediaPageBaseState {
  // ===== Class variables ===== //

  late Future<List<Show>> futurePopular;
  late Future<List<Show>> futureAiringToday;
  late Future<List<Show>> futureOnTheAir;
  late Future<List<Show>> futureTopRated;

  // ===== Lifecycle Methods ===== //

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
              searchBar("Shows"),

              // Padding
              SizedBox(height: 16),

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

              // Padding
              const SizedBox(height: 16),

              // Airing Today
              FutureBuilder<List<Show>>(
                future: futureAiringToday,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionHeader(context, "Airing Today", "Just released"),
                        SizedBox(height: 8),
                        SizedBox(
                          height: 230,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ],
                    );
                  }
                  return blankCarousel(
                    "Shows",
                    "Airing Today",
                    "Just released",
                    snapshot.data!,
                  );
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
                        sectionHeader(
                          context,
                          "On The Air",
                          "Coming this week",
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
                    "Shows",
                    "On The Air",
                    "Coming this week",
                    snapshot.data!,
                  );
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
                        sectionHeader(context, "Top Rated", "Fan favorites"),
                        SizedBox(height: 8),
                        SizedBox(
                          height: 230,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ],
                    );
                  }
                  return blankCarousel(
                    "Shows",
                    "Top Rated",
                    "Fan favorites",
                    snapshot.data!,
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
