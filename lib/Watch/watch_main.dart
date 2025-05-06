// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/Shared/utils.dart';


// Class template
class WatchMainPage extends MainPageBase {
  const WatchMainPage({super.key});

  @override
  WatchMainPageState createState() => WatchMainPageState();
}

class WatchMainPageState extends MainPageBaseState {
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