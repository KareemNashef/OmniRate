// ==================== Game Entry Page ==================== //

// Flutter imports
import 'package:flutter/material.dart';
import 'package:omnirate/API/igdb_api.dart';

// Local imports
import 'package:omnirate/BasePages/base_entry_page.dart';
import 'package:omnirate/Database/database_helper.dart';
import 'package:omnirate/Database/model_entry.dart';
import 'package:omnirate/Database/model_game.dart';
import 'package:omnirate/Shared/utils.dart';
import 'package:omnirate/BasePages/Assets/blank_carousel.dart';

// ========== Game Entry Page Class ========== //

class GameEntry extends EntryPageBase<Game> {
  const GameEntry({super.key, required super.inEntry});

  @override
  GameEntryState createState() => GameEntryState();
}

class GameEntryState extends EntryPageBaseState with TickerProviderStateMixin {
  // ===== Class variables ===== //

  // Related lists
  late Future<List<Game?>> futureExpansions;
  late Future<List<Game?>> futureDlcs;
  late Future<List<Game?>> futureSimilarGames;

  bool relatedMediaLoaded = false;

  // Entry
  late Game currentEntry;

  // ===== Lifecycle Methods ===== //

  @override
  void initState() {
    super.initState();

    currentEntry = widget.inEntry as Game;

    // Initialize animation controllers
    entryAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    entrySlideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    reviewSlideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Initialize animations
    entryScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: entryAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Entry slides left
    entrySlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.5, 0),
    ).animate(
      CurvedAnimation(
        parent: entrySlideController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // Reviews slide right
    reviewSlideAnimation = Tween<Offset>(
      begin: const Offset(1.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: reviewSlideController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // Initial state: show entry content, hide reviews content
    entrySlideController.value = 0.0;
    reviewSlideController.value = 0.0;

    getReviews();
    loadRelatedMedia();
  }

  void loadRelatedMedia() async {
    // Load expansions
    List<Game?> currentExpansions = [];
    if (currentEntry.expansions.isNotEmpty) {
      currentExpansions = await getGamesByIDs(currentEntry.expansions);
    }

    // Load dlcs
    List<Game?> currentDlcs = [];
    if (currentEntry.dlcs.isNotEmpty) {
      currentDlcs = await getGamesByIDs(currentEntry.dlcs);
    }

    // Load similar games
    List<Game?> currentSimilarGames = [];
    if (currentEntry.similarGames.isNotEmpty) {
      currentSimilarGames = await getGamesByIDs(currentEntry.similarGames);
    }

    setState(() {
      futureExpansions = Future.value(currentExpansions);
      futureDlcs = Future.value(currentDlcs);
      futureSimilarGames = Future.value(currentSimilarGames);
      relatedMediaLoaded = true;
    });
  }

  @override
  void dispose() {
    entryAnimationController.dispose();
    entrySlideController.dispose();
    reviewSlideController.dispose();
    super.dispose();
  }

  // ===== Class Widgets ===== //

  Widget blankCarousel(
    String inType,
    String inTitle,
    String inSubtitle,
    List<Game?> inEntries, {
    bool inShowArrow = false,
  }) {
    return BlankCarousel(
      inType: inType,
      inTitle: inTitle,
      inSubtitle: inSubtitle,
      inEntries: inEntries.whereType<Game>().cast<MediaEntry>().toList(),
      inShowArrow: inShowArrow,
    );
  }

  Widget gameInfo() {
    return Column(
      children: [
        // Section header
        sectionHeader(context, 'Game info', "Information about the game."),

        // Game info
        Container(
          decoration: containerDecoration(context),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              infoLine('Release date:', currentEntry.releaseDate),
              divider(),
              infoLine('Developer:', currentEntry.developer),
              divider(),
              infoLine('Genres:', currentEntry.genres.join(', ')),
              divider(),
              ExpandableText(
                label: 'Overview: ',
                content: currentEntry.overview,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget timeToBeat() {
    // Time card
    Widget buildCard(String label, String time) {
      return Container(
        decoration: containerDecoration(context),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Label
            Text(label, style: TextStyle(fontSize: 14)),
            // Padding
            SizedBox(height: 8),
            // Time
            Text(
              time,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Section header
        sectionHeader(
          context,
          'Time to Beat',
          "Average time to beat the game in hours.",
        ),

        // Times row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Haste time
            Expanded(
              child: buildCard(
                'Hastily',
                currentEntry.timeHaste == 'N/A'
                    ? 'N/A'
                    : (double.tryParse(currentEntry.timeHaste) ?? 0) > 999
                    ? '999+'
                    : currentEntry.timeHaste,
              ),
            ),
            // Padding
            SizedBox(width: 8),
            // Normal time
            Expanded(
              child: buildCard(
                'Normally',
                currentEntry.timeNormal == 'N/A'
                    ? 'N/A'
                    : (double.tryParse(currentEntry.timeNormal) ?? 0) > 999
                    ? '999+'
                    : currentEntry.timeNormal,
              ),
            ),
            // Padding
            SizedBox(width: 8),
            // Complete time
            Expanded(
              child: buildCard(
                'Completely',
                currentEntry.timeComplete == 'N/A'
                    ? 'N/A'
                    : (double.tryParse(currentEntry.timeComplete) ?? 0) > 999
                    ? '999+'
                    : currentEntry.timeComplete,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget gameContent() {
    return SlideTransition(
      position: entrySlideAnimation,
      child: Column(
        children: [
          // Add to list
          addToList(),

          // Padding
          const SizedBox(height: 8),

          // Game info
          gameInfo(),

          // Padding
          const SizedBox(height: 8),

          // Time to beat
          timeToBeat(),

          // Padding
          const SizedBox(height: 8),

          // Expansions
          FutureBuilder<List<Game?>>(
            future: futureExpansions,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return blankCarousel(
                  "Games",
                  "Expansions",
                  "Add-ons and game content extensions",
                  snapshot.data!,
                );
              } else {
                return Container();
              }
            },
          ),

          // Dlcs
          FutureBuilder<List<Game?>>(
            future: futureDlcs,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return blankCarousel(
                  "Games",
                  "DLCs",
                  "Downloadable content packs",
                  snapshot.data!,
                );
              } else {
                return Container();
              }
            },
          ),

          // Similar games
          FutureBuilder<List<Game?>>(
            future: futureSimilarGames,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return blankCarousel(
                  "Games",
                  "Similar Games",
                  "Fans also enjoyed these titles",
                  snapshot.data!,
                );
              } else {
                return Container();
              }
            },
          ),

          // Padding
          const SizedBox(height: 90),
        ],
      ),
    );
  }

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    if (relatedMediaLoaded == false) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: gradientBackground(context)),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: buttonDecoration(context),
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Loading game...",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Please wait a moment",
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        currentEntry = (await getGame(currentEntry.id, forceUpdate: true))!;
        setState(() {});
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: gradientBackground(context)),
          child: Stack(
            children: [
              // Page content
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 80, 8, 0),
                  child: Column(
                    children: [
                      // Entry main
                      entryMain(inCommentView: commentView),

                      // Padding
                      const SizedBox(height: 8),

                      // Content switcher
                      Stack(children: [gameContent(), commentContent()]),
                    ],
                  ),
                ),
              ),

              // FAB and NavBar
              Positioned(
                left: 0,
                right: 0,
                bottom: 20,
                child: Column(
                  children: [
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        final offsetAnimation = Tween<Offset>(
                          begin: Offset(0, 1),
                          end: Offset(0, 0),
                        ).animate(animation);
                        return SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        );
                      },
                      child:
                          commentView
                              ? Column(
                                children: [
                                  addCommentFAB(),
                                  const SizedBox(height: 8),
                                ],
                              )
                              : SizedBox.shrink(),
                    ),
                    navigationBar(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
