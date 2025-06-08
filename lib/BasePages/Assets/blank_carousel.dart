// ==================== Optimized Carousel ==================== //

// Flutter imports
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

// ========== Optimized Carousel Class ========== //

class BlankCarousel extends StatelessWidget {
  // ===== Input Variables ===== //
  final String inType;
  final String inTitle;
  final String inSubtitle;
  final List<MediaEntry> inEntries;
  final bool inShowArrow;

  // ===== Constructor ===== //
  const BlankCarousel({
    super.key,
    required this.inType,
    required this.inTitle,
    required this.inSubtitle,
    required this.inEntries,
    required this.inShowArrow,
  });

  // ===== Class Methods ===== //

  void _navigateToFullList(
    BuildContext context,
    String inType,
    List<MediaEntry> inEntries,
  ) {
    final pageMap = {
      "Games": () => DiscoverPage(
            inType: "Games",
            getFilteredItems: getFilteredGames,
            inDisplayItems: inEntries,
          ),
      "Shows": () => DiscoverPage(
            inType: "Shows",
            getFilteredItems: getFilteredShows,
            inDisplayItems: inEntries,
          ),
      "Movies": () => DiscoverPage(
            inType: "Movies",
            getFilteredItems: getFilteredMovies,
            inDisplayItems: inEntries,
          ),
    };

    final page = pageMap[inType]?.call();
if (page != null) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => page),
  );
}
  }

  void _navigateToEntry(BuildContext context, String inType, MediaEntry entry) {
    final pageMap = {
      "Games": () => GameEntry(inEntry: entry as Game),
      "Shows": () => ShowEntry(inEntry: entry as Show),
      "Movies": () => MovieEntry(inEntry: entry as Movie),
    };

    final page = pageMap[inType]?.call();
    if (page != null) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 250),
        ),
      );
    }
  }

  // ===== Optimized Widgets ===== //

  Widget modernGlassCarousel(
    BuildContext context,
    String inType,
    String inTitle,
    String inSubtitle,
    List<MediaEntry> inEntries, {
    bool inShowArrow = true,
  }) {
    final emptyMessages = {
      "Games": "Time to pick up a new game! 🎮",
      "Shows": "Catch up on some shows! 📺",
      "Movies": "Grab some popcorn — find a movie! 🍿",
    };

    final emptyMessage = emptyMessages[inType] ?? "Nothing here yet! ✨";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        sectionHeader(context, inTitle, inSubtitle),

        // Padding
        const SizedBox(height: 16),

        // Carousel
        SizedBox(
          height: 240,
          child: inEntries.isEmpty
              ? _buildEmptyState(context, emptyMessage)
              : _buildCarouselList(context, inType, inEntries, inShowArrow),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselList(
    BuildContext context,
    String inType,
    List<MediaEntry> inEntries,
    bool inShowArrow,
  ) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: inEntries.length + (inShowArrow ? 1 : 0),
      itemBuilder: (context, index) {
        if (inShowArrow && index == inEntries.length) {
          return _buildSeeMoreCard(context, inType, inEntries);
        }
        return _buildMediaCard(context, inType, inEntries[index]);
      },
    );
  }

  Widget _buildSeeMoreCard(
    BuildContext context,
    String inType,
    List<MediaEntry> inEntries,
  ) {
    return Container(
      width: 120,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _navigateToFullList(context, inType, inEntries),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).colorScheme.primaryContainer,
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "See more",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaCard(
    BuildContext context,
    String inType,
    MediaEntry entry,
  ) {
    return Container(
      width: 120,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _navigateToEntry(context, inType, entry),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Optimized image container
              Container(
                width: 110,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: buildImageFromUrl(entry.thumbnailUrl),
                ),
              ),

              const SizedBox(height: 12),

              // Simplified title container
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
                ),
                child: Text(
                  entry.name,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Build Method ===== //
  @override
  Widget build(BuildContext context) {
    return modernGlassCarousel(
      context,
      inType,
      inTitle,
      inSubtitle,
      inEntries,
      inShowArrow: inShowArrow,
    );
  }
}