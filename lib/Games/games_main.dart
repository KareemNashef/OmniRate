// Flutter imports
import 'package:flutter/material.dart';
import 'dart:math';

// Local imports
import 'package:omnirate/BaseClasses/base_main.dart';
import 'package:omnirate/Shared/utils.dart';

// ========== Games main page ========== //

class GamesMainPage extends MainPageBase {
  const GamesMainPage({super.key});

  @override
  GamesMainPageState createState() => GamesMainPageState();
}

class GamesMainPageState extends MainPageBaseState {
  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    // ===== UI SPRINT ===== //

    final random = Random();
    final allIndices = List<int>.generate(gamesList.length, (i) => i)
      ..shuffle(random);

    final selectedGames1 =
        allIndices.sublist(0, 4).map((i) => gamesList[i]).toList();
    final selectedPaths1 =
        allIndices.sublist(0, 4).map((i) => gamesPaths[i]).toList();

    final selectedGames2 =
        allIndices.sublist(4, 8).map((i) => gamesList[i]).toList();
    final selectedPaths2 =
        allIndices.sublist(4, 8).map((i) => gamesPaths[i]).toList();

    final selectedGames3 =
        allIndices.sublist(8, 12).map((i) => gamesList[i]).toList();
    final selectedPaths3 =
        allIndices.sublist(8, 12).map((i) => gamesPaths[i]).toList();

    // ===== UI SPRINT ===== //

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 12,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            searchBar(),
            mainCarousel(selectedPaths3, selectedGames3),
            discoverButtons("Discover New Games", "Games"),
            blankCarousel("Recent Releases", selectedPaths1, selectedGames1),
            blankCarousel("Trending", selectedPaths2, selectedGames2),
            blankCarousel("Top Rated", selectedPaths3, selectedGames3),

            // Padding
            SizedBox(height: 64),
          ],
        ),
      ),
    );
  }
}
