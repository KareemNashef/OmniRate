// ==================== Discover Page ==================== //

// Flutter imports
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// Local imports
import 'package:omnirate/Games/games_filters.dart';
import 'package:omnirate/Movies/movie_entry.dart';
import 'package:omnirate/Movies/movies_filters.dart';
import 'package:omnirate/Shared/utils.dart';
import 'package:omnirate/Shows/show_entry.dart';
import 'package:omnirate/Shows/shows_filters.dart';
import 'package:omnirate/Database/model_entry.dart';
import 'package:omnirate/Database/model_game.dart';
import 'package:omnirate/Database/model_movie.dart';
import 'package:omnirate/Database/model_show.dart';
import 'package:omnirate/Games/game_entry.dart';

// ========== Discover Page Class ========== //

class DiscoverPage extends StatefulWidget {
  // ===== Input Variables ===== //
  final String inType;
  final Future<List<MediaEntry>> Function(List<String>, String, String)?
  getFilteredItems;
  final List<MediaEntry> inDisplayItems;

  // ===== Constructor ===== //
  const DiscoverPage({
    super.key,
    required this.inType,
    this.getFilteredItems,
    required this.inDisplayItems,
  });

  @override
  State<DiscoverPage> createState() => DiscoverPageState();
}

class DiscoverPageState extends State<DiscoverPage> {
  // ===== Class Variables ===== //

  // State Variables
  List<MediaEntry> displayItems = [];
  bool isLoading = false;
  String? errorMessage;

  // Filter Variables
  int? _lastCategoryId;
  double? _lastRatingValue;
  Set<int>? _lastSelectedGenreIds;

  // Genre data for lookup
  static final Map<String, List<Map<String, dynamic>>> _genresByType = {
    "Games": genresGames,
    "Shows": genresShows,
    "Movies": genresMovies,
  };

  // ===== Lifecycle Methods ===== //

  @override
  void initState() {
    super.initState();
    displayItems = widget.inDisplayItems;
  }

  // ===== Class Methods ===== //

  Future<void> applyFilters(
    List<String> genreNames,
    String categoryName,
    String minRating,
  ) async {
    if (widget.getFilteredItems == null) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final results = await widget.getFilteredItems!(
      genreNames,
      categoryName,
      minRating,
    );
    setState(() {
      displayItems = results;
      isLoading = false;
    });
  }

  void showFilterDialog() async {
    Map<String, dynamic>? result;

    if (widget.inType == "Games") {
      result = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder:
            (context) => GamesFilterPage(
              initialCategoryId: _lastCategoryId,
              initialRatingValue: _lastRatingValue,
              initialSelectedGenreIds: _lastSelectedGenreIds,
            ),
      );
    } else if (widget.inType == "Shows") {
      result = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder:
            (context) => ShowsFilterPage(
              initialCategoryId: _lastCategoryId,
              initialRatingValue: _lastRatingValue,
              initialSelectedGenreIds: _lastSelectedGenreIds,
            ),
      );
    } else if (widget.inType == "Movies") {
      result = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder:
            (context) => MoviesFilterPage(
              initialCategoryId: _lastCategoryId,
              initialRatingValue: _lastRatingValue,
              initialSelectedGenreIds: _lastSelectedGenreIds,
            ),
      );
    }

    // Apply the filters if user didn't cancel
    if (result != null) {
      // Additional safety checks
      final genreNames = result['genreNames'];
      final categoryId = result['categoryId'];
      final minRating = result['minRating'];

      // Ensure we have the right types
      List<String> safeGenreNames = [];
      if (genreNames is List) {
        safeGenreNames = genreNames.cast<String>();
      } else if (genreNames is String) {
        safeGenreNames = [genreNames];
      }

      String safeCategoryId = categoryId?.toString() ?? '0';
      String safeMinRating = minRating?.toString() ?? '0.0';

      // Store the applied filters for next time
      _lastCategoryId = int.tryParse(safeCategoryId) ?? 0;
      _lastRatingValue = (double.tryParse(safeMinRating) ?? 0.0) * 10;

      // Convert genre names back to IDs for storage
      _lastSelectedGenreIds = <int>{};
      for (String genreName in safeGenreNames) {
        int? genreId = getGenreIdByName(genreName, widget.inType);
        if (genreId != null) {
          _lastSelectedGenreIds!.add(genreId);
        }
      }

      await applyFilters(safeGenreNames, safeCategoryId, safeMinRating);
    }
  }

  int? getGenreIdByName(String genreName, String type) {
    final genres = _genresByType[type];
    if (genres == null) return null;

    try {
      final genre = genres.firstWhere((genre) => genre['name'] == genreName);
      return genre['id'] as int?;
    } catch (e) {
      // Genre not found
      return null;
    }
  }

  IconData getTypeIcon() {
    switch (widget.inType) {
      case "Games":
        return Icons.games;
      case "Movies":
        return Icons.movie;
      case "Shows":
        return Icons.tv;
      default:
        return Icons.explore;
    }
  }
  // ===== Class Widgets ===== //

  Widget listGrid() {
    // Loading screen
    if (isLoading) {
      return GridView.builder(
        // Grid Properties
        padding: const EdgeInsets.all(20),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.5,
        ),
        itemCount: 6,

        // Item Builder
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            // Colors
            baseColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            highlightColor: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: 0.5),

            // Shape
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.2),
                ),
                color: Colors.white,
              ),
            ),
          );
        },
      );
    }

    // Error screen
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

    // Empty screen
    if (displayItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Container(
            // Decoration
            decoration: containerDecoration(context),
            padding: const EdgeInsets.all(40),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    // Border
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.2),
                    ),

                    // Background
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withValues(alpha: 0.8),
                        Theme.of(
                          context,
                        ).colorScheme.tertiaryContainer.withValues(alpha: 0.8),
                      ],
                    ),

                    // Shape
                    shape: BoxShape.circle,
                  ),

                  child: Icon(
                    Icons.search,
                    size: 48,
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                  ),
                ),

                // Padding
                const SizedBox(height: 32),

                // Title
                Text(
                  "Ready to explore?",
                  style: TextStyle(
                    fontSize: 24,
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w700,
                  ),
                ),

                // Padding
                const SizedBox(height: 16),

                // Subtitle
                Text(
                  "Use filters to discover amazing ${widget.inType.toLowerCase()} tailored to your taste.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Build grid
    return GridView.builder(
      // Grid Properties
      padding: const EdgeInsets.all(20),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.5,
      ),
      itemCount: displayItems.length,

      // Item Builder
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Widget page;
            switch (widget.inType) {
              case "Games":
                page = GameEntry(inEntry: displayItems[index] as Game);
                break;
              case "Shows":
                page = ShowEntry(inEntry: displayItems[index] as Show);
                break;
              case "Movies":
                page = MovieEntry(inEntry: displayItems[index] as Movie);
                break;
              default:
                return;
            }
            Navigator.push(context, MaterialPageRoute(builder: (_) => page));
          },

          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: gradientContainer(context),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 12,
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Thumbnail with rating badge
                Expanded(
                  child: Stack(
                    children: [
                      // Thumbnail
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 9 / 16,
                            child: buildImageFromUrl(
                              displayItems[index].thumbnailUrl,
                            ),
                          ),
                        ),
                      ),

                      // Rating badge
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.amber.withValues(alpha: 0.9),
                                Colors.orange.withValues(alpha: 0.8),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                displayItems[index].rating.toString() == "0.0"
                                    ? "N/A"
                                    : displayItems[index].rating.toString(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Padding
                const SizedBox(height: 8),

                // Title
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Text(
                    displayItems[index].name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
              builder:
                  (context) => SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: GamesFilterPage(),
                  ),
            );
          } else if (widget.inType == "Shows") {
            result = await showModalBottomSheet<Map<String, dynamic>>(
              context: context,
              isScrollControlled: true,
              builder:
                  (context) => SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: ShowsFilterPage(),
                  ),
            );
          } else if (widget.inType == "Movies") {
            result = await showModalBottomSheet<Map<String, dynamic>>(
              context: context,
              isScrollControlled: true,
              builder:
                  (context) => SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: MoviesFilterPage(),
                  ),
            );
          }

          // Apply the filters if user didn't cancel
          if (result != null) {
            // Additional safety checks
            final genreNames = result['genreNames'];
            final categoryId = result['categoryId'];
            final minRating = result['minRating'];

            // Ensure we have the right types
            List<String> safeGenreNames = [];
            if (genreNames is List) {
              safeGenreNames = genreNames.cast<String>();
            } else if (genreNames is String) {
              safeGenreNames = [genreNames];
            }

            String safeCategoryId = categoryId?.toString() ?? '0';
            String safeMinRating = minRating?.toString() ?? '0.0';

            await applyFilters(safeGenreNames, safeCategoryId, safeMinRating);
          }
        },
      ),
    );
  }

  Widget customFloatingActionButton() {
    return Container(
      // Theme
      decoration: buttonDecoration(context),

      // Logic
      child: FloatingActionButton.extended(
        onPressed: showFilterDialog,
        backgroundColor: Colors.transparent,
        elevation: 0,

        // Text
        label: Text(
          "Filters",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),

        // Icon
        icon: Icon(
          Icons.tune_rounded,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          size: 24,
        ),
      ),
    );
  }

  Widget customHeader() {
    return Container(
      decoration: containerDecoration(context),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Icon
          Icon(
            getTypeIcon(),
            size: 48,
            color: Theme.of(
              context,
            ).colorScheme.onPrimaryContainer.withValues(alpha: 0.9),
          ),

          // Padding
          const SizedBox(height: 16),

          // Title
          Text(
            "Discover ${widget.inType}",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              letterSpacing: -0.5,
            ),
          ),

          // Padding
          const SizedBox(height: 8),

          // Subtitle
          Text(
            "Find your next favorite ${widget.inType.toLowerCase()}",
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(
                context,
              ).colorScheme.onPrimaryContainer.withValues(alpha: 0.9),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    return Container(
      // Background
      decoration: BoxDecoration(gradient: gradientBackground(context)),

      // Foreground
      child: Scaffold(
        backgroundColor: Colors.transparent,

        // Floating Action Button
        floatingActionButton: customFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

        // Body
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(top: 100, bottom: 80),
          child: Column(
            children: [customHeader(), const SizedBox(height: 40), listGrid()],
          ),
        ),
      ),
    );
  }
}
