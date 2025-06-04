// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/BaseClasses/base_discover.dart';
import 'package:omnirate/Games/game_entry.dart';
import 'package:omnirate/Shows/show_entry.dart';
import 'package:omnirate/Movies/movie_entry.dart';

import 'package:omnirate/BaseClasses/Assets/animated_entry.dart';

// ========== Main page base ========== //
class MainPageBase extends StatefulWidget {
  const MainPageBase({super.key});

  @override
  MainPageBaseState createState() => MainPageBaseState();
}

class MainPageBaseState extends State<MainPageBase> {
  // ===== Class Widgets ===== //

  // Search Bar
  Widget searchBar(String inType) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: TextField(
        decoration: InputDecoration(
          // Search Text
          hintText: 'Search...',

          // Search Icon
          prefixIcon: Icon(Icons.search),

          // Filter
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: InkWell(
              onTap: () {
                // Open the discover page
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) {
                      return DiscoverPageBase(inType: inType);
                    },
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Filter'),
                    SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.tune, size: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  // Advanced Search
  Widget advancedSearch(String inTitle, String inType) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            padding: EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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
          icon: Icon(Icons.tune),
          label: Text(
            "Advanced Search",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  // Main Carousel
  Widget mainCarousel(
    String inType,
    List<String> inPaths,
    List<String> inTitles, {
    List<String> inRatings = const [],
    List<String> inArtworks = const [],
  }) {
    return SizedBox(
      height: 290,
      child: PageView.builder(
        itemCount: inTitles.length,
        controller: PageController(viewportFraction: 1),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Widget page;
              switch (inType) {
                case "Games":
                  page = GameEntry(inTitle: inTitles[index]);
                  break;
                case "Shows":
                  page = ShowEntry();
                  break;
                case "Movies":
                  page = MovieEntry();
                  break;
                default:
                  return;
              }
              Navigator.push(context, MaterialPageRoute(builder: (_) => page));
            },
            child: AnimatedBackgroundCard(
              inTitle: inTitles[index],
              inPath: inPaths[index],
              inRating: inRatings[index],
              inArtwork: inArtworks[index], // TODO
            ),
          );
        },
      ),
    );
  }

  // Blank Carousel
  Widget blankCarousel(
    String inType,
    String inTitle,
    List<String> inPaths,
    List<String> inTitles,
  ) {
    String emptyMessage;
    switch (inType) {
      case "Games":
        emptyMessage = "Time to pick up a new game!";
        break;
      case "Shows":
        emptyMessage = "Catch up on some shows!";
        break;
      case "Movies":
        emptyMessage = "Grab some popcorn — find a movie!";
        break;
      default:
        emptyMessage = "Nothing here yet!";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        SizedBox(height: 8),
        SizedBox(
          height: 230,
          child:
              (inPaths.isEmpty || inTitles.isEmpty)
                  ? Center(
                    child: Text(
                      emptyMessage,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  )
                  : PageView.builder(
                    itemCount: inPaths.length,
                    padEnds: false,
                    controller: PageController(viewportFraction: 0.3),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Widget page;
                          switch (inType) {
                            case "Games":
                              page = GameEntry(inTitle: inTitles[index]);
                              break;
                            case "Shows":
                              page = ShowEntry();
                              break;
                            case "Movies":
                              page = MovieEntry();
                              break;
                            default:
                              return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => page),
                          );
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 90,
                              height: 160,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                    inPaths[index].contains('file')
                                        ? 'https://www.igdb.com/assets/no_cover_show-ef1e36c00e101c2fb23d15bb80edd9667bbf604a12fc0267a66033afea320c65.png'
                                        : inPaths[index],
                                  ),
                                  fit: BoxFit.cover,
                                ), // TODO
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              inTitles[index],
                              maxLines: 3,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
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
