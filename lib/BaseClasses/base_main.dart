// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/Settings/settings_main.dart';
import 'package:omnirate/BaseClasses/base_discover.dart';

// ========== Main page base ========== //
class MainPageBase extends StatefulWidget {
  const MainPageBase({super.key});

  @override
  MainPageBaseState createState() => MainPageBaseState();
}

class MainPageBaseState extends State<MainPageBase> {
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
  Widget mainCarousel(List<String> inPaths, List<String> inTitles) {
    return SizedBox(
      height: 290,
      child: PageView.builder(
        itemCount: inTitles.length,
        controller: PageController(viewportFraction: 1),
        itemBuilder: (context, index) {
          return Card(
            color: Theme.of(context).colorScheme.surfaceContainer,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Thumbnail
                Container(
                  width: 135,
                  height: 240,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(inPaths[index]),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                // Padding
                SizedBox(width: 10),

                // Title and rating
                SizedBox(
                  width: 180,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Title
                      Text(
                        inTitles[index],
                        maxLines: 3,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),

                      // Padding
                      SizedBox(height: 8),

                      // Rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          SizedBox(width: 4),
                          Text(
                            '8.5',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Genres button
  Widget discoverButtons(String inTitle, String inType) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox(
        width: 200,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            padding: EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: () {
              // Open the discover page
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) {
                    return DiscoverPageBase(inType: inType);
                  },
                ),
              );

          },
          icon: Icon(Icons.travel_explore),
          label: Text(
            inTitle,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  // Blank Carousel
  Widget blankCarousel(
    String inTitle,
    List<String> inPaths,
    List<String> inTitles,
  ) {
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
          height: 230,
          child: PageView.builder(
            itemCount: inPaths.length,
            padEnds: false,
            controller: PageController(viewportFraction: 0.3),
            itemBuilder: (context, index) {
              return Column(
                mainAxisAlignment:
                    MainAxisAlignment.start, // Align the items at the top
                crossAxisAlignment:
                    CrossAxisAlignment
                        .center, // Center the children horizontally
                children: [
                  // Thumbnail
                  Container(
                    width: 90,
                    height: 160,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(inPaths[index]),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  // Padding
                  SizedBox(height: 8),

                  // Title - It is now horizontally centered
                  Text(
                    inTitles[index],
                    maxLines: 3,
                    textAlign:
                        TextAlign
                            .center, // Centers the text within the text widget
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
