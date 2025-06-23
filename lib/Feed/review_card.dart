// ==================== Vertical Review Card (Improved) ==================== //

// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/Feed/review_model.dart';
import 'package:omnirate/Games/game_entry.dart';
import 'package:omnirate/Movies/movie_entry.dart';
import 'package:omnirate/Shared/firebase_service.dart';
import 'package:omnirate/Shared/utils.dart';
import 'package:omnirate/Shows/show_entry.dart';
import 'package:omnirate/Database/database_helper.dart';

// ========== Vertical Review Card Class ========== //

class ReviewCard extends StatelessWidget {
  // ===== Input Variables ===== //

  final Review review;

  // ===== Constructor ===== //

  const ReviewCard({super.key, required this.review});

  // ===== Helper Methods ===== //

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return 'Recently';
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Future<String?> _getArtworkUrl() async {
    // Using a switch for better readability and scalability
    switch (review.mediaType) {
      case "MediaType.game":
        final game = await getGame(review.entryId);
        return game?.artworkUrl;
      case "MediaType.show":
        final show = await getShow(review.entryId);
        return show?.artworkUrl;
      case "MediaType.movie":
        final movie = await getMovie(review.entryId);
        return movie?.artworkUrl;
      default:
        return null;
    }
  }

  void _openEntry(BuildContext context) async {
    Widget? page;

    switch (review.mediaType) {
      case "MediaType.game":
        final game = await getGame(review.entryId);
        if (game == null) return;
        page = GameEntry(inEntry: game);
        break;
      case "MediaType.show":
        final show = await getShow(review.entryId);
        if (show == null) return;
        page = ShowEntry(inEntry: show);
        break;
      case "MediaType.movie":
        final movie = await getMovie(review.entryId);
        if (movie == null) return;
        page = MovieEntry(inEntry: movie);
        break;
      default:
        return;
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
          Positioned.fill(
            child: FutureBuilder<String?>(
              future: _getArtworkUrl(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasData && snapshot.data != null) {
                  return buildImageFromUrl(snapshot.data!);
                }
                return Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                );
              },
            ),
          ),

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
                _UserInfo(
                  review: review,
                  timestamp: _formatTimestamp(review.timestamp),
                ),
                const Spacer(),
                _MediaTitleAndRating(review: review),
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
          text: review.review,
          style: textTheme.bodyLarge?.copyWith(
            height: 1.6,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

// ========== Reusable Component Widgets ========== //

// Displays the User's Avatar, Name, and the review timestamp.
class _UserInfo extends StatelessWidget {
  final Review review;
  final String timestamp;

  const _UserInfo({required this.review, required this.timestamp});

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        // --- Avatar ---
        FutureBuilder<int?>(
          future: firebaseService.getAvatarIndexFirebase(review.userId),
          builder: (context, snapshot) {
            final index = snapshot.data ?? 0;
            return CircleAvatar(
              radius: 18,
              backgroundColor: colorScheme.primary,
              child: CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage(
                  'assets/ProfilePics/pic_${index + 1}.png',
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 12),
        // --- Username and Time ---
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              review.userName,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              timestamp,
              style: textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Displays the Media's Title and Rating.
class _MediaTitleAndRating extends StatelessWidget {
  final Review review;
  const _MediaTitleAndRating({required this.review});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // --- Media Title ---
        Expanded(
          child: Text(
            review.entryName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(width: 16),
        // --- Rating Indicator ---
        ratingsIndicator(context, review.rating, opaque: true),
      ],
    );
  }
}
