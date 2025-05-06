// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/BaseClasses/base_main.dart';


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
