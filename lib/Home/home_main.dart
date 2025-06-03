// Flutter imports
import 'package:flutter/material.dart';
import 'dart:math';

// Local imports
import 'package:omnirate/BaseClasses/base_main.dart';
import 'package:omnirate/BaseClasses/base_list.dart';
import 'package:omnirate/Settings/settings_main.dart';
import 'package:omnirate/Shared/utils.dart';
import 'package:omnirate/Shared/list_use.dart';

// ========== Home main page ========== //

class HomeMainPage extends MainPageBase {
  const HomeMainPage({super.key});

  @override
  HomeMainPageState createState() => HomeMainPageState();
}

class HomeMainPageState extends MainPageBaseState {
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
    // ===== UI SPRINT ===== //

    final random = Random();
    final indices = <int>{};

    // Pick 4 unique random indices
    while (indices.length < 3) {
      indices.add(random.nextInt(gamesList.length));
    }

    final selectedGames = indices.map((i) => gamesList[i]).toList();
    final selectedGamesPaths = indices.map((i) => gamesPaths[i]).toList();

    final selectedShows = indices.map((i) => showsList[i]).toList();
    final selectedShowsPaths = indices.map((i) => showsPaths[i]).toList();

    final selectedMovies = indices.map((i) => moviesList[i]).toList();
    final selectedMoviesPaths = indices.map((i) => moviesPaths[i]).toList();

    // ===== UI SPRINT ===== //

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 12,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            welcomeText(),
            SizedBox(height: 8),
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
            blankCarousel(
              "Ongoing Games",
              selectedGamesPaths,
              selectedGames,
            ),
            blankCarousel(
              "Ongoing Shows",
              selectedShowsPaths,
              selectedShows,
            ),
            blankCarousel(
              "Ongoing Movies",
              selectedMoviesPaths,
              selectedMovies,
            ),

            // Padding
            SizedBox(height: 64),
          ],
        ),
      ),
    );
  }
}
