// ==================== Optimized Carousel ==================== //

// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/Shared/utils.dart';

// ========== Optimized Carousel Class ========== //

class CastCarousel extends StatelessWidget {
  // ===== Input Variables ===== //
  final String mediaType;
  final List<String> inNames;
  final List<String> inLinks;

  // ===== Constructor ===== //
  const CastCarousel({
    super.key,
    required this.mediaType,
    required this.inNames,
    required this.inLinks,
  });

  // ===== Class Widgets ===== //

  Widget modernGlassCarousel(
    BuildContext context,
    List<String> inNames,
    List<String> inLinks,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        sectionHeader(context, "Cast", "Cast members of this $mediaType."),

        // Padding
        const SizedBox(height: 16),

        // Carousel
        SizedBox(
          height: 240,
          child:
              inNames.isEmpty
                  ? _buildEmptyState(context)
                  : _buildCarouselList(context, inNames, inLinks),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
          'No cast members found.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselList(
    BuildContext context,
    List<String> inNames,
    List<String> inLinks,
  ) {
    return Container(
      decoration: containerDecoration(context),
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 220,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: inNames.length,
          itemBuilder: (context, index) {
            return _buildMediaCard(
              context,
              inNames[index],
              inLinks[index],
              index,
            );
          },
        ),
      ),
    );
  }

  Widget _buildMediaCard(
    BuildContext context,
    String inName,
    String inLink,
    int index,
  ) {
    return Container(
      width: 100,
      margin: EdgeInsets.only(
        left: index == 0 ? 0 : 8,
        right: index == inNames.length - 1 ? 0 : 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Thumbnail
          Container(
            width: 90,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: -5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: buildImageFromUrl(inLink),
            ),
          ),

          // Padding
          const SizedBox(height: 8),

          // Title
          Text(
            inName,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  // ===== Build Method ===== //
  @override
  Widget build(BuildContext context) {
    return modernGlassCarousel(context, inNames, inLinks);
  }
}
