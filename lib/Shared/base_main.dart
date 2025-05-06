// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/Settings/settings_main.dart';

// ===== Main page base ===== //
class MainPageBase extends StatefulWidget {
  const MainPageBase({super.key});

  @override
  MainPageBaseState createState() => MainPageBaseState();
}

class MainPageBaseState extends State<MainPageBase> {
  // ===== Class Variables ===== //

  // Text controllers

  // ===== Class Methods ===== //

  // ===== Class Widgets ===== //

  // Search bar
  Widget searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        children: [
          // Search bar
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ),

          SizedBox(width: 8),

          // Settings button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
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

  // Main Carousel
  Widget mainCarousel() {
    return SizedBox(
      height: 240,
      child: PageView.builder(
        itemCount: 5,
        controller: PageController(viewportFraction: 1),
        itemBuilder: (context, index) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // Thumbnail
              Container(
                width: 135,
                height: 240,
                decoration: BoxDecoration(
                  color:
                      Colors.primaries[DateTime.now().millisecondsSinceEpoch %
                          Colors.primaries.length],
                  borderRadius: BorderRadius.circular(
                    12,
                  ),
                ),
              ),

              // Padding
              SizedBox(width: 10),

              // Title and description
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Entry $index',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    'Entry description',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // Genres button
  Widget discoverButtons() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: Size(120, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {},
        child: Text('Genres'),
      ),
    );
  }

  // Blank Carousel
  Widget blankCarousel(String inTitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            inTitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),

        // Padding
        SizedBox(height: 8),

        // Carousel
        SizedBox(
          height: 200,
          child: PageView.builder(
            itemCount: 5,
            padEnds: false,
            controller: PageController(viewportFraction: 0.3),
            itemBuilder: (context, index) {
              return Column(
                children: [
                  // Thumbnail
                  Container(
                    width: 90,
                    height: 160,
                    decoration: BoxDecoration(
                      color:
                          Colors.primaries[DateTime.now()
                                  .millisecondsSinceEpoch %
                              Colors.primaries.length],
                      borderRadius: BorderRadius.circular(12),
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
    return Container();
  }
}
