// Flutter imports
import 'package:flutter/material.dart';
import 'package:omnirate/Games/game_entry.dart';

// Local imports
import 'package:omnirate/Games/games_filters.dart';
import 'package:omnirate/Movies/movie_entry.dart';
import 'package:omnirate/Movies/movies_filters.dart';
import 'package:omnirate/Shows/show_entry.dart';
import 'package:omnirate/Shows/shows_filters.dart';

// ========== List page base ========== //

class DiscoverPageBase extends StatefulWidget {
  final String inType;
  // Add the function as a parameter
  final Future<Map<String, String>> Function(List<String>, String, String)? getFilteredItems;

  // Constructor with required parameters
  const DiscoverPageBase({
    super.key, 
    required this.inType,
    this.getFilteredItems,
  });

  @override
  State<DiscoverPageBase> createState() => DiscoverPageBaseState();
}

class DiscoverPageBaseState extends State<DiscoverPageBase> {
  // ===== Class Variables ===== //

  Map<String, String> displayItems = {}; // title -> thumbnail URL
  bool isLoading = false;
  String? errorMessage;

  // ===== Class Methods ===== //

  // Initialize with default empty state
  @override
  void initState() {
    super.initState();
    // Start with empty results - user needs to apply filters to see content
  }

  // Method to handle filter application
  Future<void> _applyFilters(List<String> genreNames, String categoryName, String minRating) async {
    if (widget.getFilteredItems == null) return;
    
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Debug print to see what we're passing
      print('Applying filters:');
      print('  Genre names: $genreNames (type: ${genreNames.runtimeType})');
      print('  Category: $categoryName (type: ${categoryName.runtimeType})');
      print('  Min rating: $minRating (type: ${minRating.runtimeType})');
      
      final results = await widget.getFilteredItems!(genreNames, categoryName, minRating);
      setState(() {
        displayItems = results;
        isLoading = false;
      });
    } catch (e, stackTrace) {
      print('Error in _applyFilters: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        errorMessage = 'Error loading results: $e';
        isLoading = false;
      });
    }
  }

  // ===== Class Widgets ===== //

  // Build list grid from dynamic data
  Widget listGrid() {
    if (isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              SizedBox(height: 16),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      );
    }

    if (displayItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Apply filters to discover ${widget.inType.toLowerCase()}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final titles = displayItems.keys.toList();
    final thumbnails = displayItems.values.toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 16,
        childAspectRatio: 100 / 200, // Thumbnail height + spacing
      ),
      itemCount: titles.length,
      itemBuilder: (context, index) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                          Widget page;
                          switch (widget.inType) {
                            case "Games":
                              page = GameEntry(inTitle: titles[index]);
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
              child: Container(
                width: 90,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[300], // Placeholder background
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    thumbnails[index],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey[600],
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              titles[index],
              maxLines: 3,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        );
      },
    );
  }

  // Filter button
  Widget filterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(Icons.filter_list),
        label: Text('Filters'),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () async {
          Map<String, dynamic>? result;
          
          if (widget.inType == "Games") {
            result = await showModalBottomSheet<Map<String, dynamic>>(
              context: context,
              isScrollControlled: true,
              builder: (context) => SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: GamesFilterPage(),
              ),
            );
          } else if (widget.inType == "Shows") {
            result = await showModalBottomSheet<Map<String, dynamic>>(
              context: context,
              isScrollControlled: true,
              builder: (context) => SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: ShowsFilterPage(),
              ),
            );
          } else if (widget.inType == "Movies") {
            result = await showModalBottomSheet<Map<String, dynamic>>(
              context: context,
              isScrollControlled: true,
              builder: (context) => SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: MoviesFilterPage(),
              ),
            );
          }

          // Apply the filters if user didn't cancel
          if (result != null) {
            // Additional safety checks
            final genreNames = result['genreNames'];
            final categoryId = result['categoryId']; // Now using categoryId
            final minRating = result['minRating'];
            
            // Debug prints
            print('Filter result received:');
            print('  Raw result: $result');
            print('  Genre names: $genreNames (${genreNames.runtimeType})');
            print('  Category ID: $categoryId (${categoryId.runtimeType})');
            print('  Min rating: $minRating (${minRating.runtimeType})');
            
            // Ensure we have the right types
            List<String> safeGenreNames = [];
            if (genreNames is List) {
              safeGenreNames = genreNames.cast<String>();
            } else if (genreNames is String) {
              safeGenreNames = [genreNames];
            }
            
            String safeCategoryId = categoryId?.toString() ?? '0';
            String safeMinRating = minRating?.toString() ?? '0.0';
            
            await _applyFilters(safeGenreNames, safeCategoryId, safeMinRating);
          }
        },
      ),
    );
  }

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Remove the back arrow
        automaticallyImplyLeading: false,

        // Set the height
        toolbarHeight: 120,

        title: Column(
          children: [
            Text(
              "Advanced Search",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Padding
            SizedBox(height: 8),

            // Filter
            filterButton(),
          ],
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(children: [listGrid()]),
      ),
    );
  }
}