// ==================== Movie Entry Page ==================== //

// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/BasePages/base_entry_page.dart';
import 'package:omnirate/Database/database_helper.dart';
import 'package:omnirate/Database/model_movie.dart';
import 'package:omnirate/Shared/utils.dart';

// ========== Movie Entry Page Class ========== //

class MovieEntry extends EntryPageBase {
  const MovieEntry({super.key, required super.inEntry});

  @override
  MovieEntryState createState() => MovieEntryState();
}

class MovieEntryState extends EntryPageBaseState with TickerProviderStateMixin {
  // ===== Class Variables ===== //

  late Movie currentMovie;
  bool isLoaded = false;

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final movie = await getMovie(widget.inEntry.id);
      if (movie != null) {
        setState(() {
          currentMovie = movie;
          isLoaded = true;
        });
      }
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

  // Movie info
  Widget movieInfo() {
    return Column(
      children: [
        // Section header
        sectionHeader(context, 'Movie info', "Information about the movie."),

        // Movie info
        Container(
          decoration: containerDecoration(context),

          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              infoLine("Release Date: ", currentMovie.releaseStatus),
              divider(),
              infoLine("Genres: ", currentMovie.genres.join(', ')),
              divider(),

              // Story with Read More toggle
              ExpandableText(label: 'Story: ', content: currentMovie.overview),
            ],
          ),
        ),
      ],
    );
  }

  Widget budgetAndRevenue() {
    String formatMoney(dynamic amount) {
      if (amount == 'N/A' || amount == '0') return 'N/A';
      final numVal = num.tryParse(amount.toString()) ?? 0;
      if (numVal >= 1e9) return '\$${(numVal / 1e9).toStringAsFixed(1)}B';
      if (numVal >= 1e6) return '\$${(numVal / 1e6).toStringAsFixed(1)}M';
      if (numVal >= 1e3) return '\$${(numVal / 1e3).toStringAsFixed(1)}K';
      return '\$${numVal.toStringAsFixed(0)}';
    }

    // Data card
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

            // Data
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
      children: [
        // Section header
        sectionHeader(
          context,
          'Budget and Revenue',
          "Information about the movie's budget and revenue.",
        ),

        // Cards
        Row(
          children: [
            Expanded(
              child: buildCard('Budget', formatMoney(currentMovie.budget)),
            ),
            SizedBox(width: 8),
            Expanded(
              child: buildCard('Revenue', formatMoney(currentMovie.revenue)),
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
        width: double.infinity, // Set width to fill the available space
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

  Widget movieContent() {
    return SlideTransition(
      position: entrySlideAnimation,
      child: Column(
        children: [
          // Add to list
          addToList(),
          // Padding
          const SizedBox(height: 8),
          // Game info
          movieInfo(),
          // Padding
          const SizedBox(height: 8),
          // Time to beat
          budgetAndRevenue(),
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
    if (isLoaded == false) {
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
                  "Loading Movie...",
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
                    Stack(children: [movieContent(), commentContent()]),
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
