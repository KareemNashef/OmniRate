// Flutter imports
import 'package:flutter/material.dart';
import 'dart:math';

// Local imports
import 'package:omnirate/BaseClasses/base_main.dart';
import 'package:omnirate/Shared/utils.dart';


// ========== Shows main page ========== //

class ShowsMainPage extends MainPageBase {
  const ShowsMainPage({super.key});

  @override
  ShowsMainPageState createState() => ShowsMainPageState();
}

class ShowsMainPageState extends MainPageBaseState {

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {

    // ===== UI SPRINT ===== //

    final random = Random();
    final allIndices = List<int>.generate(showsList.length, (i) => i)
      ..shuffle(random);

    final selectedShows1 =
        allIndices.sublist(0, 4).map((i) => showsList[i]).toList();
    final selectedPaths1 =
        allIndices.sublist(0, 4).map((i) => showsPaths[i]).toList();

    final selectedShows2 =
        allIndices.sublist(4, 8).map((i) => showsList[i]).toList();
    final selectedPaths2 =
        allIndices.sublist(4, 8).map((i) => showsPaths[i]).toList();

    final selectedShows3 =
        allIndices.sublist(8, 12).map((i) => showsList[i]).toList();
    final selectedPaths3 =
        allIndices.sublist(8, 12).map((i) => showsPaths[i]).toList();

    // ===== UI SPRINT ===== //

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 12,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            searchBar("Shows"),
            // mainCarousel("Shows",selectedPaths3, selectedShows3),
            // blankCarousel("Shows", "Upcoming Releases", selectedPaths1, selectedShows1),
            // blankCarousel("Shows","Latest", selectedPaths2, selectedShows2),
            // blankCarousel("Shows","Top Rated", selectedPaths3, selectedShows3),
            
            // Padding
            SizedBox(height: 64),
          ]
        ),
      ),
    );
  }
}