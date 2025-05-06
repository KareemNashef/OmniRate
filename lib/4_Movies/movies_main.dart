// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/BaseClasses/base_main.dart';

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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 12,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            searchBar(),
            mainCarousel(),
            discoverButtons(),
            blankCarousel("Recent Releases"),
            blankCarousel("Trending"),
            blankCarousel("Top Rated"),
          ],
        ),
      ),
    );
  }
}