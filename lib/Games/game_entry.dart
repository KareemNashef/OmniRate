// ==================== Game Entry Page ==================== //

// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/BasePages/base_entry_page.dart';
import 'package:omnirate/Database/model_game.dart';
import 'package:omnirate/Shared/utils.dart';

// ========== Game Entry Page Class ========== //

class GameEntry extends EntryPageBase<Game> {
  const GameEntry({super.key, required super.inEntry});

  @override
  GameEntryState createState() => GameEntryState();
}

class GameEntryState extends EntryPageBaseState with TickerProviderStateMixin {
  // ===== Lifecycle Methods ===== //

  @override
  void initState() {
    super.initState();

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
  }

  @override
  void dispose() {
    entryAnimationController.dispose();
    entrySlideController.dispose();
    reviewSlideController.dispose();
    super.dispose();
  }

  // ===== Class Widgets ===== //

  Widget gameInfo() {
    final game = widget.inEntry as Game;
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
              infoLine('Release date:', game.releaseDate),
              divider(),
              infoLine('Developer:', game.developer),
              divider(),
              infoLine('Genres:', game.genres.join(', ')),
              divider(),
              ExpandableText(label: 'Overview: ', content: game.overview),
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
                (widget.inEntry as Game).timeHaste == 'N/A'
                    ? 'N/A'
                    : (double.tryParse((widget.inEntry as Game).timeHaste) ??
                            0) >
                        999
                    ? '999+'
                    : (widget.inEntry as Game).timeHaste,
              ),
            ),
            // Padding
            SizedBox(width: 8),
            // Normal time
            Expanded(
              child: buildCard(
                'Normally',
                (widget.inEntry as Game).timeNormal == 'N/A'
                    ? 'N/A'
                    : (double.tryParse((widget.inEntry as Game).timeNormal) ??
                            0) >
                        999
                    ? '999+'
                    : (widget.inEntry as Game).timeNormal,
              ),
            ),
            // Padding
            SizedBox(width: 8),
            // Complete time
            Expanded(
              child: buildCard(
                'Completely',
                (widget.inEntry as Game).timeComplete == 'N/A'
                    ? 'N/A'
                    : (double.tryParse((widget.inEntry as Game).timeComplete) ??
                            0) >
                        999
                    ? '999+'
                    : (widget.inEntry as Game).timeComplete,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget relatedMedia() {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainer,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Related Media:", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
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
        ),
      ),
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
          // const SizedBox(height: 8),
          // Related media
          // relatedMedia(),
          // Padding
          const SizedBox(height: 90),
        ],
      ),
    );
  }

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
