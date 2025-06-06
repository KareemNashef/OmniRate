// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/BaseClasses/base_main.dart';
import 'package:omnirate/Database/model_movie.dart';
import 'package:omnirate/API/tmdb_api.dart';

// ========== Movies main page ========== //

class MoviesMainPage extends MainPageBase {
  const MoviesMainPage({super.key});

  @override
  MoviesMainPageState createState() => MoviesMainPageState();
}

class MoviesMainPageState extends MainPageBaseState {
  // ===== Class variables ===== //

  late Future<List<Movie>> futurePopular;
  late Future<List<Movie>> futureUpcoming;
  late Future<List<Movie>> futureNowPlaying;
  late Future<List<Movie>> futureTopRated;

  // ===== Class Initialization ===== //

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
    return SingleChildScrollView(
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
            SizedBox(height: 20),

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
                return blankCarousel("Movies", "Upcoming", snapshot.data!);
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
                return blankCarousel("Movies", "Now Playing", snapshot.data!);
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
                return blankCarousel("Movies", "Top Rated", snapshot.data!);
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
