// Flutter imports
import 'package:flutter/material.dart';
import 'dart:math';

// Local imports
import 'package:omnirate/BaseClasses/base_main.dart';
import 'package:omnirate/Shared/utils.dart';

// ========== Assistant main page ========== //

class AssistantMainPage extends MainPageBase {
  const AssistantMainPage({super.key});

  @override
  AssistantMainPageState createState() => AssistantMainPageState();
}

class AssistantMainPageState extends MainPageBaseState {

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {

    // ===== UI SPRINT ===== //

    final random = Random();
    final indices = <int>{};

    // Pick 4 unique random indices
    while (indices.length < 5) {
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
            // searchBar(),
            //mainCarousel(),
            // discoverButtons(),
            blankCarousel("Recommended Games",  selectedGamesPaths, selectedGames),
            blankCarousel("Recommended Shows", selectedShowsPaths, selectedShows),
            blankCarousel("Recommended Movies", selectedMoviesPaths, selectedMovies), 
          ],
        ),
      ),
    );
  }
}