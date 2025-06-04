// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/BaseClasses/base_discover.dart';
import 'package:omnirate/Games/game_entry.dart';
import 'package:omnirate/Shows/show_entry.dart';
import 'package:omnirate/Movies/movie_entry.dart';
import 'package:omnirate/API/igdb_api.dart';

import 'package:omnirate/BaseClasses/Assets/animated_entry.dart';

// ========== Main page base ========== //
class MainPageBase extends StatefulWidget {
  const MainPageBase({super.key});

  @override
  MainPageBaseState createState() => MainPageBaseState();
}

class MainPageBaseState extends State<MainPageBase> {
  final TextEditingController _searchController = TextEditingController();
  List<MapEntry<String, String>> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  // ===== Class Widgets ===== //

// Search Bar
Widget searchBar(String inType) {
  return Column(
    children: [
      // Search Input Section
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search games...',
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () => _performSearch(),
              ),
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey[600],
                    ),
                    onPressed: () => _clearSearch(),
                  ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => _openFilterPage(inType),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Filter',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.tune,
                              size: 14,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ),

      // Loading Indicator
      if (_isSearching)
        Container(
          padding: const EdgeInsets.all(16),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),

      // Search Results
      if (_searchResults.isNotEmpty && !_isSearching)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Results Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Search Results (${_searchResults.length})',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Results List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _searchResults.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                ),
                itemBuilder: (context, index) {
                  final entry = _searchResults[index];
                  return _buildSearchResultTile(entry);
                },
              ),
            ],
          ),
        ),
    ],
  );
}

// Helper method to build individual search result tiles
Widget _buildSearchResultTile(MapEntry<String, String> entry) {
  return Container(
    padding: const EdgeInsets.all(12),
    child: GestureDetector(
      onTap: () {
Widget page = GameEntry(inTitle: entry.key);
// TODO: Add switch statement

// switch (inType) {
//   case "Games":
//     page = GameEntry(inTitle: entry.key);
//     break;
//   case "Shows":
//     page = ShowEntry();
//     break;
//   case "Movies":
//     page = MovieEntry();
//     break;
//   default:
//     return;
// }
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => page),
                          );
      },
      child: Row(
        children: [
          // Thumbnail with 9:16 aspect ratio
          Container(
            width: 54, // 9:16 ratio: 54x96
            height: 96,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                entry.value,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Icon(
                    Icons.image_not_supported,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Game Title
          Expanded(
            child: Text(
              entry.key,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.3,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          
          // Chevron Arrow
          Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ],
      ),
    ),
  );
}

// Helper method to perform search
void _performSearch() async {
  final searchText = _searchController.text.trim();
  if (searchText.isEmpty) {
    _clearSearch();
    return;
  }

  setState(() => _isSearching = true);
  
  try {
    final results = await searchGamesByName(searchText);
    setState(() {
      _searchResults = results.entries.toList();
      _isSearching = false;
    });
  } catch (error) {
    setState(() => _isSearching = false);
    // Handle error - could show a snackbar or error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Search failed. Please try again.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// Helper method to clear search
void _clearSearch() {
  setState(() {
    _searchController.clear();
    _searchResults.clear();
    _isSearching = false;
  });
}

// Helper method to open filter page
void _openFilterPage(String inType) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => DiscoverPageBase(
        inType: inType,
        getFilteredItems: getFilteredGames,
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
