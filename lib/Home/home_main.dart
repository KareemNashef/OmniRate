// Flutter imports
import 'package:flutter/material.dart';
import 'dart:math';

// Local imports
import 'package:omnirate/BaseClasses/base_main.dart';
import 'package:omnirate/BaseClasses/base_list.dart';
import 'package:omnirate/Database/database_helper.dart';
import 'package:omnirate/Database/model_game.dart';
import 'package:omnirate/Database/model_movie.dart';
import 'package:omnirate/Database/model_show.dart';
import 'package:omnirate/Settings/settings_main.dart';
import 'package:omnirate/Shared/user_data.dart';
import 'package:omnirate/Shared/utils.dart';
import 'package:omnirate/Shared/list_use.dart';

// ========== Home main page ========== //

class HomeMainPage extends MainPageBase {
  const HomeMainPage({super.key});

  @override
  HomeMainPageState createState() => HomeMainPageState();
}

class HomeMainPageState extends MainPageBaseState {
  // ===== Class variables ===== //

  late Future<List<UserMediaEntry>> futureGames;
  late Future<List<UserMediaEntry>> futureShows;
  late Future<List<UserMediaEntry>> futureMovies;

  List<Game> ongoingGames = [];
  List<Show> ongoingShows = [];
  List<Movie> ongoingMovies = [];

  bool mediaLoaded = false;

  // ===== Class Initialization ===== //

  @override
  void initState() {
    super.initState();
    futureGames = getMediaByStatus("Games", "Current");
    futureShows = getMediaByStatus("Shows", "Current");
    futureMovies = getMediaByStatus("Movies", "Current");

  _initOngoingMedia();
  }

  void _initOngoingMedia() async {
    final games = await futureGames;
    final shows = await futureShows;
    final movies = await futureMovies;

    ongoingGames =
        (await Future.wait(
          games.map((e) => getGame(e.name)),
        )).whereType<Game>().toList();
    ongoingShows =
        (await Future.wait(
          shows.map((e) => getShow(e.name)),
        )).whereType<Show>().toList();
    ongoingMovies =
        (await Future.wait(
          movies.map((e) => getMovie(e.name)),
        )).whereType<Movie>().toList();

    mediaLoaded = true;
    setState(() {});
  }

  // ===== Class Widgets ===== //

  // Welcome Text
  Widget welcomeText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Welcome Text
          FutureBuilder<String?>(
            future: getUsername(),
            builder: (context, snapshot) {
              final name = snapshot.data ?? 'User';
              return Text(
                'Hello $name!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            },
          ),

          // Settings
          ElevatedButton(
            // Button style
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12),
            ),

            // Button action
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },

            // Button icon
            child: Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.primary,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  // Lists buttons
  Widget listsButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Games List
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            minimumSize: Size(100, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) {
                  return const ListPageBase(listType: "Games");
                },
              ),
            );
          },
          child: Text('Games'),
        ),

        SizedBox(width: 12),

        // Shows List
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            minimumSize: Size(100, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) {
                  return const ListPageBase(listType: "Shows");
                },
              ),
            );
          },
          child: Text('Shows'),
        ),

        SizedBox(width: 12),

        // Movies List
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            minimumSize: Size(100, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) {
                  return const ListPageBase(listType: "Movies");
                },
              ),
            );
          },
          child: Text('Movies'),
        ),
      ],
    );
  }

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {

      if (!mediaLoaded) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            "Loading your media...",
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 12,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            welcomeText(),
            Text(
              "My Lists",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            listsButtons(),
            SizedBox(height: 8),

            // Ongoing Games
            blankCarousel(
              "Games",
              "Ongoing Games",
              ongoingGames,),

            // Ongoing Shows
            blankCarousel(
              "Shows",
              "Ongoing Shows",
              ongoingShows,),

            // Ongoing Movies
            blankCarousel(
              "Movies",
              "Ongoing Movies",
              ongoingMovies,),

            // Padding
            SizedBox(height: 64),
          ],
        ),
      ),
    );
  }
}
