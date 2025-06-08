// ==================== Movies Main Page ==================== //

// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/BasePages/media_page.dart';
import 'package:omnirate/Database/model_movie.dart';
import 'package:omnirate/API/tmdb_api.dart';
import 'package:omnirate/Shared/utils.dart';

// ========== Movies Main Page Class ========== //

class MoviesMainPage extends MediaPageBase {
  const MoviesMainPage({super.key});

  @override
  MoviesMainPageState createState() => MoviesMainPageState();
}

class MoviesMainPageState extends MediaPageBaseState {
  // ===== Class variables ===== //

  late Future<List<Movie>> futurePopular;
  late Future<List<Movie>> futureUpcoming;
  late Future<List<Movie>> futureNowPlaying;
  late Future<List<Movie>> futureTopRated;

  // ===== Lifecycle Methods ===== //

  @override
  void initState() {
    super.initState();
    futurePopular = getPopularMovies();
    futureUpcoming = getUpcomingMovies();
    futureNowPlaying = getNowPlayingMovies();
    futureTopRated = getTopRatedMovies();
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
              searchBar("Movies"),

              // Padding
              SizedBox(height: 16),

              // Main Carousel
              FutureBuilder<List<Movie>>(
                future: futurePopular,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return SizedBox(
                      height: 290,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  return mainCarousel("Movies", snapshot.data!);
                },
              ),

              // Padding
              const SizedBox(height: 16),

              // Upcoming
              FutureBuilder<List<Movie>>(
                future: futureUpcoming,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionHeader(context, "Upcoming", "Soon in theaters"),
                        SizedBox(height: 8),
                        SizedBox(
                          height: 230,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ],
                    );
                  }
                  return blankCarousel(
                    "Movies",
                    "Upcoming",
                    "Soon in theaters",
                    snapshot.data!,
                  );
                },
              ),

              // Now Playing
              FutureBuilder<List<Movie>>(
                future: futureNowPlaying,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionHeader(
                          context,
                          "Now Playing",
                          "Fresh on screens",
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
                    "Movies",
                    "Now Playing",
                    "Fresh on screens",
                    snapshot.data!,
                  );
                },
              ),

              // Top Rated
              FutureBuilder<List<Movie>>(
                future: futureTopRated,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionHeader(
                          context,
                          "Top Rated",
                          "Must-watch classics",
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
                    "Movies",
                    "Top Rated",
                    "Must-watch classics",
                    snapshot.data!,
                  );
                },
              ),

              // Padding
              SizedBox(height: 90),
            ],
          ),
        ),
      ),
    );
  }
}
