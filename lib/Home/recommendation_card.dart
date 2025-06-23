// ==================== Recommendation Card ==================== //

// Flutter imports
import 'package:flutter/material.dart';
import 'package:omnirate/Database/model_entry.dart';
import 'package:omnirate/Database/model_game.dart';
import 'package:omnirate/Database/model_movie.dart';
import 'package:omnirate/Database/model_show.dart';

// Local imports
import 'package:omnirate/Games/game_entry.dart';
import 'package:omnirate/Movies/movie_entry.dart';
import 'package:omnirate/Shared/utils.dart';
import 'package:omnirate/Shows/show_entry.dart';

// ========== Recommendation Card Class ========== //

class RecommendationCard extends StatelessWidget {
  // ===== Input Variables ===== //

  final MediaEntry inEntry;
  final String inReason;

  // ===== Constructor ===== //

  const RecommendationCard({
    super.key,
    required this.inEntry,
    required this.inReason,
  });

  // ===== Helper Methods ===== //

  void _openEntry(BuildContext context) async {
    Widget? page;

    switch (inEntry.mediaType) {
      case MediaType.game:
        page = GameEntry(inEntry: inEntry as Game);
        break;
      case MediaType.show:
        page = ShowEntry(inEntry: inEntry as Show);
        break;
      case MediaType.movie:
        page = MovieEntry(inEntry: inEntry as Movie);
        break;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => page!));
  }

  // ===== Build Method ===== //
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: containerDecoration(context),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _openEntry(context),
              child: _buildHeader(context),
            ),
            _buildReviewContent(context),
          ],
        ),
      ),
    );
  }

  // ===== Private Build Helper Widgets ===== //

  // Builds the top section of the card with the artwork and user info.
  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          // --- Artwork Background ---
          Positioned.fill(child: buildImageFromUrl(inEntry.artworkUrl)),

          // --- Gradient Overlay ---
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),

          // --- Header Content ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // --- Media Title ---
                    Expanded(
                      child: Text(
                        inEntry.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // --- Rating Indicator ---
                    ratingsIndicator(context, inEntry.rating, opaque: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Builds the main review text section.
  Widget _buildReviewContent(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Text.rich(
        // The actual review text
        TextSpan(
          text: inReason,
          style: textTheme.bodyLarge?.copyWith(
            height: 1.6,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
