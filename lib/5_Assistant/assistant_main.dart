// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/BaseClasses/base_main.dart';

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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 12,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            searchBar(),
            //mainCarousel(),
            // discoverButtons(),
            // blankCarousel("Recent Releases"),
            // blankCarousel("Trending"),
            // blankCarousel("Top Rated"),
          ],
        ),
      ),
    );
  }
}