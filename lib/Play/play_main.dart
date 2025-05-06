// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/Shared/utils.dart';


// Class template
class PlayMainPage extends MainPageBase {
  const PlayMainPage({super.key});

  @override
  PlayMainPageState createState() => PlayMainPageState();
}

class PlayMainPageState extends MainPageBaseState {
  // ===== Class Variables ===== //

  // Text controllers

  // ===== Class Methods ===== //

  // ===== Class Widgets ===== //

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
