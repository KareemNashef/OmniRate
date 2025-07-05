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

class DiscoverPageState extends State<DiscoverPage>
    with TickerProviderStateMixin {
  // ===== Class Variables ===== //

  // State Variables
  List<MediaEntry> displayItems = [];
  bool isLoading = false;
  String? errorMessage;
  bool hasFiltersApplied = false;
  bool showQuickFilters = false;

  // Animation Controllers
  late AnimationController _filterButtonController;
  late AnimationController _quickFiltersController;

  // Filter Variables
  int? _lastCategoryId;
  double? _lastRatingValue;
  Set<int>? _lastSelectedGenreIds;
  List<String> _appliedFilters = [];

  // Genre data for lookup
  static final Map<String, List<Map<String, dynamic>>> _genresByType = {
    "Games": genresGames,
    "Shows": genresShows,
    "Movies": genresMovies,
  };

  // Quick filter options
  final Map<String, List<String>> quickFilterOptions = {
    "Games": ["Popular", "New Releases", "Indie", "Multiplayer"],
    "Shows": ["Trending", "Binge-worthy", "Comedy", "Drama"],
    "Movies": ["Popular", "Recent", "Action", "Comedy", "Drama"],
  };

  // ===== Lifecycle Methods ===== //

  @override
  void initState() {
    super.initState();
    displayItems = widget.inDisplayItems;

    _filterButtonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _quickFiltersController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Show welcome animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (displayItems.isEmpty) {
        setState(() {
          showQuickFilters = true;
        });
        _quickFiltersController.forward();
      }
    });
  }

  @override
  void dispose() {
    _filterButtonController.dispose();
    _quickFiltersController.dispose();
    super.dispose();
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

    try {
      final results = await widget.getFilteredItems!(
        genreNames,
        categoryName,
        minRating,
      );

      setState(() {
        displayItems = results;
        isLoading = false;
        hasFiltersApplied =
            genreNames.isNotEmpty || categoryName != '0' || minRating != '0.0';

        // Update applied filters display
        _appliedFilters = [];
        if (genreNames.isNotEmpty) _appliedFilters.addAll(genreNames);
        if (categoryName != '0') _appliedFilters.add('Category: $categoryName');
        if (minRating != '0.0') _appliedFilters.add('Rating: $minRating+');
      });

      _filterButtonController.forward();
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load results. Please try again.';
      });
    }
  }

  Future<void> applyQuickFilter(String filterName) async {
    // Convert quick filter to appropriate filter parameters
    List<String> genreNames = [];
    String categoryName = '0';
    String minRating = '0.0';

    switch (filterName) {
      case "Popular":
        minRating = '7.0';
        break;
      case "New Releases":
      case "Recent":
        // This would need to be handled by your backend
        categoryName = '1'; // Assuming 1 = recent
        break;
      case "Trending":
        minRating = '6.0';
        break;
      case "Binge-worthy":
        genreNames = ["Drama", "Thriller"];
        break;
      default:
        genreNames = [filterName];
    }

    await applyFilters(genreNames, categoryName, minRating);
  }

  void clearFilters() async {
    setState(() {
      hasFiltersApplied = false;
      _appliedFilters = [];
      displayItems = widget.inDisplayItems;
    });

    _lastCategoryId = null;
    _lastRatingValue = null;
    _lastSelectedGenreIds = null;

    _filterButtonController.reverse();
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
      final genreNames = result['genreNames'];
      final categoryId = result['categoryId'];
      final minRating = result['minRating'];

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
      _lastRatingValue = double.tryParse(safeMinRating) ?? 0.0;

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

  Widget quickFiltersSection() {
    if (!showQuickFilters || hasFiltersApplied) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _quickFiltersController,
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.5),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _quickFiltersController,
              curve: Curves.easeOutBack,
            ),
          ),
          child: FadeTransition(
            opacity: _quickFiltersController,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: containerDecoration(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Quick Filters",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Get started with these popular choices:",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        quickFilterOptions[widget.inType]!.map((filter) {
                          return GestureDetector(
                            onTap: () => applyQuickFilter(filter),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outline.withValues(alpha: 0.3),
                                ),
                                color: Theme.of(
                                  context,
                                ).colorScheme.surface.withValues(alpha: 0.5),
                              ),
                              child: Text(
                                filter,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget appliedFiltersSection() {
    if (!hasFiltersApplied || _appliedFilters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_alt,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                "Active Filters",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: clearFilters,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                  ),
                  child: Text(
                    "Clear All",
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children:
                _appliedFilters.map((filter) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

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

  Widget customFloatingActionButton() {
    return AnimatedBuilder(
      animation: _filterButtonController,
      builder: (context, child) {
        return Container(
          decoration: buttonDecoration(context),
          child: FloatingActionButton.extended(
            onPressed: showFilterDialog,
            backgroundColor: Colors.transparent,
            elevation: 0,
            label: Text(
              hasFiltersApplied ? "Edit Filters" : "Advanced Filters",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            icon: AnimatedRotation(
              turns: _filterButtonController.value * 0.5,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                hasFiltersApplied ? Icons.tune : Icons.filter_list,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                size: 22,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget customHeader() {
    final bool isInitialState = displayItems.isEmpty && !hasFiltersApplied;

    return Container(
      decoration: containerDecoration(context),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            getTypeIcon(),
            size: 48,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            shadows: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Discover ${widget.inType}",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text.rich(
            isInitialState
                ? TextSpan(
                  // Default style for the paragraph
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(text: "Use "),
                    TextSpan(
                      text: "advanced filters",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const TextSpan(text: " to narrow down your results."),
                  ],
                )
                : TextSpan(
                  text:
                      "Find your next favorite ${widget.inType.toLowerCase()}",
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: gradientBackground(context)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: customFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(top: 100, bottom: 100),
          child: Column(
            children: [
              customHeader(),
              const SizedBox(height: 24),
              appliedFiltersSection(),
              const SizedBox(height: 8),
              listGrid(),
            ],
          ),
        ),
      ),
    );
  }
}
