// ==================== Media Page Base ==================== //

// Flutter imports
import 'dart:ui';
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/BasePages/discover_page.dart';
import 'package:omnirate/Database/model_entry.dart';
import 'package:omnirate/Database/model_game.dart';
import 'package:omnirate/Database/model_movie.dart';
import 'package:omnirate/Database/model_show.dart';
import 'package:omnirate/Games/game_entry.dart';
import 'package:omnirate/Shared/utils.dart';
import 'package:omnirate/Shows/show_entry.dart';
import 'package:omnirate/Movies/movie_entry.dart';
import 'package:omnirate/API/igdb_api.dart';
import 'package:omnirate/API/tmdb_api.dart';
import 'package:omnirate/BasePages/Assets/blank_carousel.dart';
import 'package:omnirate/BasePages/Assets/animated_entry.dart';

// ========== Media Page Base Class ========== //

class MediaPageBase extends StatefulWidget {
  const MediaPageBase({super.key});

  @override
  MediaPageBaseState createState() => MediaPageBaseState();
}

class MediaPageBaseState extends State<MediaPageBase> {
  // ==== Class Variables ==== //

  // Controllers
  final TextEditingController _searchController = TextEditingController();

  // Loading
  bool _isSearching = false;

  // ===== Lifecycle Methods ===== //

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ===== Class Methods ===== //

  void showSearchResultsModal(String inType, List<MediaEntry> results) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder:
                (context, scrollController) => ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: gradientBackground(context),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  size: 24,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Search Results (${results.length})',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: Icon(
                                    Icons.close,
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          Expanded(
                            child:
                                results.isEmpty
                                    ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.search_off,
                                            size: 64,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant
                                                .withValues(alpha: 0.5),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No results found',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color:
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Try adjusting your search terms',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant
                                                  .withValues(alpha: 0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    : ListView.separated(
                                      controller: scrollController,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      itemCount: results.length,
                                      separatorBuilder:
                                          (_, __) => const SizedBox(height: 8),
                                      itemBuilder:
                                          (_, index) => _buildSearchResultTile(
                                            inType,
                                            results[index],
                                          ),
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          ),
    );
  }

  void performSearch(String inType) async {
    final searchText = _searchController.text.trim();
    if (searchText.isEmpty) {
      clearSearch();
      return;
    }

    setState(() => _isSearching = true);

    try {
      List<MediaEntry> results;
      switch (inType) {
        case "Games":
          results = await searchGamesByName(searchText);
          break;
        case "Shows":
          results = await searchShowsByName(searchText);
          break;
        case "Movies":
          results = await searchMoviesByName(searchText);
          break;
        default:
          return;
      }

      setState(() {
        _isSearching = false;
      });

      // Show results in modal
      showSearchResultsModal(inType, results);
    } catch (error) {
      setState(() => _isSearching = false);

      if (!mounted) return;

      // Handle error - could show a snackbar or error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Search failed. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void clearSearch() {
    setState(() {
      _searchController.clear();
      _isSearching = false;
    });
  }

  void openFilterPage(String inType) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (context) => DiscoverPage(
              inType: inType,
              getFilteredItems:
                  (inType == "Games"
                      ? getFilteredGames
                      : (inType == "Shows"
                          ? getFilteredShows
                          : getFilteredMovies)),
              inDisplayItems: [],
            ),
      ),
    );
  }

  // ===== Class Widgets ===== //

  Widget searchBar(String inType) {
    return Container(
      // Padding
      margin: const EdgeInsets.symmetric(horizontal: 12),

      // Theme
      decoration: containerDecoration(context),

      // Content
      child: TextField(
        controller: _searchController,
        style: TextStyle(fontSize: 16),
        decoration: InputDecoration(
          // Text
          hintText: "Search $inType...",
          hintStyle: TextStyle(color: Colors.grey[500]),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),

          // Border
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),

          // Icon
          prefixIcon:
              _isSearching
                  ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                  : Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),

          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cancel Search
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[600]),
                  onPressed: clearSearch,
                ),

              // Filter button
              Container(
                // Padding
                margin: const EdgeInsets.only(right: 8),

                // Theme
                decoration: buttonDecoration(context),

                // Content
                child: IconButton(
                  icon: Icon(
                    Icons.tune,
                    size: 20,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  onPressed: () => openFilterPage(inType),
                ),
              ),
            ],
          ),
        ),
        onSubmitted: (_) => performSearch(inType),
      ),
    );
  }

  Widget _buildSearchResultTile(String inType, MediaEntry entry) {
    return Container(
      // Theme
      decoration: buttonDecoration(context),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Widget page;
            switch (inType) {
              case "Games":
                page = GameEntry(inEntry: entry as Game);
                break;
              case "Shows":
                page = ShowEntry(inEntry: entry as Show);
                break;
              case "Movies":
                page = MovieEntry(inEntry: entry as Movie);
                break;
              default:
                return;
            }
            Navigator.push(context, MaterialPageRoute(builder: (_) => page));
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Thumbnail with 9:16 aspect ratio
                Container(
                  width: 54, // 9:16 ratio: 54x96
                  height: 96,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: buildImageFromUrl(entry.thumbnailUrl),
                  ),
                ),

                const SizedBox(width: 16),

                // Title
                Expanded(
                  child: Text(
                    entry.name,
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
        ),
      ),
    );
  }

  Widget mainCarousel(String inType, List<MediaEntry> inEntries) {
    // Create a very large item count for infinite scrolling
    final int infiniteCount = 1000000;
    final int actualCount = inEntries.length;

    return SizedBox(
      height: 290,
      child: PageView.builder(
        itemCount: infiniteCount,
        controller: PageController(
          viewportFraction: 1,
          initialPage: infiniteCount ~/ 2,
        ),
        itemBuilder: (context, index) {
          final actualIndex = index % actualCount;

          return GestureDetector(
            onTap: () {
              Widget page;
              switch (inType) {
                case "Games":
                  page = GameEntry(inEntry: inEntries[actualIndex] as Game);
                  break;
                case "Shows":
                  page = ShowEntry(inEntry: inEntries[actualIndex] as Show);
                  break;
                case "Movies":
                  page = MovieEntry(inEntry: inEntries[actualIndex] as Movie);
                  break;
                default:
                  return;
              }
              Navigator.push(context, MaterialPageRoute(builder: (_) => page));
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AnimatedBackgroundCard(inEntry: inEntries[actualIndex]),
            ),
          );
        },
      ),
    );
  }

  Widget blankCarousel(
    String inType,
    String inTitle,
    String inSubtitle,
    List<MediaEntry> inEntries, {
    bool inShowArrow = true,
  }) {
    return BlankCarousel(
      inType: inType,
      inTitle: inTitle,
      inSubtitle: inSubtitle,
      inEntries: inEntries,
      inShowArrow: inShowArrow,
    );
  }

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
