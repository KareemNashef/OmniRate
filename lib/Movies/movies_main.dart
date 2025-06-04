// Flutter imports
import 'package:flutter/material.dart';
import 'dart:math';

// Local imports
import 'package:omnirate/BaseClasses/base_main.dart';
import 'package:omnirate/Shared/utils.dart';

// ========== Movies main page ========== //

class MoviesMainPage extends MainPageBase {
  const MoviesMainPage({super.key});

  @override
  MoviesMainPageState createState() => MoviesMainPageState();
}

class MoviesMainPageState extends MainPageBaseState {
  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    // ===== UI SPRINT ===== //

    final random = Random();
    final allIndices = List<int>.generate(moviesList.length, (i) => i)
      ..shuffle(random);

    final selectedMovies1 =
        allIndices.sublist(0, 4).map((i) => moviesList[i]).toList();
    final selectedPaths1 =
        allIndices.sublist(0, 4).map((i) => moviesPaths[i]).toList();

    final selectedMovies2 =
        allIndices.sublist(4, 8).map((i) => moviesList[i]).toList();
    final selectedPaths2 =
        allIndices.sublist(4, 8).map((i) => moviesPaths[i]).toList();

    final selectedMovies3 =
        allIndices.sublist(8, 12).map((i) => moviesList[i]).toList();
    final selectedPaths3 =
        allIndices.sublist(8, 12).map((i) => moviesPaths[i]).toList();

    // ===== UI SPRINT ===== //

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 12,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            searchBar("Movies"),
            mainCarousel("Movies",selectedPaths3, selectedMovies3),
            blankCarousel("Movies","Upcoming Releases", selectedPaths1, selectedMovies1),
            blankCarousel("Movies","Latest", selectedPaths2, selectedMovies2),
            blankCarousel("Movies","Top Rated", selectedPaths3, selectedMovies3),

            // Padding
            SizedBox(height: 64),
          ],
        ),
      ),
    );
  }
}
