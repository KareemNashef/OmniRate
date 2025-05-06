// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/Shared/utils.dart';
import 'package:omnirate/Shared/settings_main.dart';

// Class template
class HomeMainPage extends StatefulWidget {
  const HomeMainPage({super.key});

  @override
  State<HomeMainPage> createState() => HomeMainPageState();
}

class HomeMainPageState extends State<HomeMainPage> {
  // ===== Class Variables ===== //

  // ===== Class Methods ===== //

  // ===== Class Widgets ===== //

  // Welcome Text
  Widget welcomeText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Welcome Text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Username',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Text(
                'Hours Played: X',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              Text(
                'Hours Watched: X',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
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
                  return const ListPageBase();
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
                  return const ListPageBase();
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
                  return const ListPageBase();
                },
              ),
            );
          },
          child: Text('Movies'),
        ),
      ],
    );
  }

  // Continue Playing Carousel
  Widget continuePlaying() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            "Continue Playing",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),

        SizedBox(height: 8),

        // Carousel
        SizedBox(
          height: 200,
          child: PageView.builder(
            itemCount: 5,
            padEnds: false,
            controller: PageController(viewportFraction: 0.4),
            itemBuilder: (context, index) {
              return Column(
                children: [
                  // Thumbnail
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    width: 90,
                    height: 160,
                    decoration: BoxDecoration(
                      color:
                          Colors.primaries[DateTime.now()
                                  .millisecondsSinceEpoch %
                              Colors.primaries.length],
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // Circular border with radius 12
                    ),
                  ),

                  // Padding
                  SizedBox(height: 8),

                  // Title
                  Text(
                    "Entry $index",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // Continue Watching Carousel
  Widget continueWatching() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            "Continue Watching",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),

        SizedBox(height: 8),

        // Carousel
        SizedBox(
          height: 200,
          child: PageView.builder(
            itemCount: 5,
            padEnds: false,
            controller: PageController(viewportFraction: 0.4),
            itemBuilder: (context, index) {
              return Column(
                children: [
                  // Thumbnail
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    width: 90,
                    height: 160,
                    decoration: BoxDecoration(
                      color:
                          Colors.primaries[DateTime.now()
                                  .millisecondsSinceEpoch %
                              Colors.primaries.length],
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // Circular border with radius 12
                    ),
                  ),

                  // Padding
                  SizedBox(height: 8),

                  // Title
                  Text(
                    "Entry $index",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

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
            continuePlaying(),
            continueWatching(),
          ],
        ),
      ),
    );
  }
}
