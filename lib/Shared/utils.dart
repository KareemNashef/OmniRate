// ==================== Utils ==================== //

// Flutter imports
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

// ========== Stock thumbnails for onboarding ========== //

List<String> gamesPaths = [
  "assets/Debug/Games/1.png",
  "assets/Debug/Games/2.png",
  "assets/Debug/Games/3.png",
  "assets/Debug/Games/4.png",
  "assets/Debug/Games/5.png",
  "assets/Debug/Games/6.png",
  "assets/Debug/Games/7.png",
  "assets/Debug/Games/8.png",
  "assets/Debug/Games/9.png",
];

List<String> showsPaths = [
  "assets/Debug/Shows/1.png",
  "assets/Debug/Shows/2.png",
  "assets/Debug/Shows/3.png",
  "assets/Debug/Shows/4.png",
  "assets/Debug/Shows/5.png",
  "assets/Debug/Shows/6.png",
  "assets/Debug/Shows/7.png",
  "assets/Debug/Shows/8.png",
  "assets/Debug/Shows/9.png",
];

List<String> moviesPaths = [
  "assets/Debug/Movies/1.png",
  "assets/Debug/Movies/2.png",
  "assets/Debug/Movies/3.png",
  "assets/Debug/Movies/4.png",
  "assets/Debug/Movies/5.png",
  "assets/Debug/Movies/6.png",
  "assets/Debug/Movies/7.png",
  "assets/Debug/Movies/8.png",
  "assets/Debug/Movies/9.png",
];

// ========== Constant Maps ========== //

final List<Map<String, dynamic>> genresGames = [
  {"id": 33, "name": "Arcade"},
  {"id": 31, "name": "Adventure"},
  {"id": 32, "name": "Indie"},
  {"id": 36, "name": "MOBA"},
  {"id": 2, "name": "Point-and-click"},
  {"id": 5, "name": "Shooter"},
  {"id": 9, "name": "Puzzle"},
  {"id": 4, "name": "Fighting"},
  {"id": 10, "name": "Racing"},
  {"id": 11, "name": "Real Time Strategy (RTS)"},
  {"id": 12, "name": "Role-playing (RPG)"},
  {"id": 13, "name": "Simulator"},
  {"id": 14, "name": "Sport"},
  {"id": 15, "name": "Strategy"},
  {"id": 16, "name": "Turn-based strategy (TBS)"},
  {"id": 24, "name": "Tactical"},
  {"id": 25, "name": "Hack and slash/Beat 'em up"},
  {"id": 26, "name": "Quiz/Trivia"},
  {"id": 30, "name": "Pinball"},
  {"id": 7, "name": "Music"},
  {"id": 8, "name": "Platform"},
  {"id": 34, "name": "Visual Novel"},
  {"id": 35, "name": "Card & Board Game"},
];

final List<Map<String, dynamic>> categoriesGames = [
  {"id": 0, "name": "Base Game"},
  {"id": 1, "name": "DLC"},
  {"id": 2, "name": "Expansion"},
];

final List<Map<String, dynamic>> genresShows = [
  {"id": 10759, "name": "Action & Adventure"},
  {"id": 16, "name": "Animation"},
  {"id": 35, "name": "Comedy"},
  {"id": 80, "name": "Crime"},
  {"id": 99, "name": "Documentary"},
  {"id": 18, "name": "Drama"},
  {"id": 10751, "name": "Family"},
  {"id": 10762, "name": "Kids"},
  {"id": 9648, "name": "Mystery"},
  {"id": 10763, "name": "News"},
  {"id": 10764, "name": "Reality"},
  {"id": 10765, "name": "Sci-Fi & Fantasy"},
  {"id": 10766, "name": "Soap"},
  {"id": 10767, "name": "Talk"},
  {"id": 10768, "name": "War & Politics"},
  {"id": 37, "name": "Western"},
];

final List<Map<String, dynamic>> genresMovies = [
  {"id": 28, "name": "Action"},
  {"id": 12, "name": "Adventure"},
  {"id": 16, "name": "Animation"},
  {"id": 35, "name": "Comedy"},
  {"id": 80, "name": "Crime"},
  {"id": 99, "name": "Documentary"},
  {"id": 18, "name": "Drama"},
  {"id": 10751, "name": "Family"},
  {"id": 14, "name": "Fantasy"},
  {"id": 36, "name": "History"},
  {"id": 27, "name": "Horror"},
  {"id": 10402, "name": "Music"},
  {"id": 9648, "name": "Mystery"},
  {"id": 10749, "name": "Romance"},
  {"id": 878, "name": "Science Fiction"},
  {"id": 10770, "name": "TV Movie"},
  {"id": 53, "name": "Thriller"},
  {"id": 10752, "name": "War"},
  {"id": 37, "name": "Western"},
];

// ========== Helper Classes ========== //

// Expandable story text widget
class ExpandableText extends StatefulWidget {
  final String label;
  final String content;

  const ExpandableText({required this.label, required this.content, super.key});

  @override
  ExpandableTextState createState() => ExpandableTextState();
}

class ExpandableTextState extends State<ExpandableText> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          textAlign: TextAlign.justify,
          text: TextSpan(
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.85),
            ),
            children: [
              TextSpan(
                text: widget.label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              TextSpan(
                text:
                    expanded || widget.content.length <= 120
                        ? widget.content
                        : '${widget.content.substring(0, 120)}...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () => setState(() => expanded = !expanded),
          child: Text(
            expanded ? 'Read less' : 'Read more',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// ========== Helper Builds ========== //

LinearGradient gradientBackground(context) => LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Theme.of(context).colorScheme.primaryContainer,
    Theme.of(context).colorScheme.tertiaryContainer,
  ],
);

BoxDecoration buttonDecoration(context) => BoxDecoration(
  borderRadius: BorderRadius.circular(20),
  border: Border.all(
    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
  ),

  // Background
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.8),
      Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.8),
    ],
  ),

  // Glow
  boxShadow: [
    BoxShadow(
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
      blurRadius: 4,
    ),
  ],
);

BoxDecoration containerDecoration(context) => BoxDecoration(
  // Border
  borderRadius: BorderRadius.circular(16),
  border: Border.all(
    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
  ),

  // Background
  color: Theme.of(
    context,
  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
);

// ============
LinearGradient gradientContainer(context) => LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.4),
    Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.2),
  ],
);
// ============

Widget sectionHeader(BuildContext context, String title, String subtitle) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget ratingsIndicator(
  BuildContext context,
  String inRating, {
  bool opaque = false,
}) {
  final double? rating = double.tryParse(inRating);
  final bool hasValidRating = rating != null && rating > 0.0;
  final colorScheme = Theme.of(context).colorScheme;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color:
          hasValidRating
              ? (opaque
                  ? Colors.amber.shade100
                  : Colors.amber.withValues(alpha: 0.12))
              : (opaque
                  ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.8)
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color:
            hasValidRating
                ? (opaque
                    ? Colors.amber.shade300
                    : Colors.amber.withValues(alpha: 0.4))
                : colorScheme.outline.withValues(alpha: opaque ? 0.7 : 0.3),
        width: 1.2,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          hasValidRating ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 16,
          color:
              hasValidRating
                  ? Colors.amber.shade700
                  : colorScheme.outlineVariant,
        ),
        const SizedBox(width: 6),
        Text(
          hasValidRating ? rating.toStringAsFixed(1) : 'Not Rated',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color:
                hasValidRating
                    ? Colors.amber.shade800
                    : colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ),
  );
}

Widget buildImageFromUrl(String inURL) => CachedNetworkImage(
  imageUrl: inURL,
  fit: BoxFit.cover,
  placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
  errorWidget: (_, __, ___) => Icon(Icons.broken_image),
);

// ===== Glass Container =====


class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(32),
    this.borderRadius = 24,
  });

  BoxDecoration boxDecoration(context) => BoxDecoration(
    borderRadius: BorderRadius.circular(borderRadius),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: 0.1),
        Colors.white.withValues(alpha: 0.05),
      ],
    ),
    border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: Colors.white.withValues(alpha: 0.05),
        blurRadius: 20,
        offset: const Offset(0, -4),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: boxDecoration(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
