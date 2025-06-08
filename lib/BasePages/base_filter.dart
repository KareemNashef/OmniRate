// ==================== Filter Modal Base ==================== //

// Flutter imports
import 'dart:ui';
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/Shared/utils.dart';

// ========== Filter Modal Base ========== //

abstract class FilterModalBase extends StatefulWidget {
  // ===== Input Variables ===== //
  final int? initialCategoryId;
  final double? initialRatingValue;
  final Set<int>? initialSelectedGenreIds;

  // ===== Constructor ===== //
  const FilterModalBase({
    super.key,
    this.initialCategoryId,
    this.initialRatingValue,
    this.initialSelectedGenreIds,
  });
}

abstract class FilterModalBaseState<T extends FilterModalBase>
    extends State<T> {
  // ===== Class Variables ===== //

  // Common variables
  List<Map<String, dynamic>> get genres;
  List<Map<String, dynamic>> get categories;
  String get genresTitle => "Genres";
  String get categoriesTitle => "Categories";
  String get ratingTitle => "Minimum Rating";
  late int selectedCategoryId;
  late double ratingValue;
  late Set<int> selectedGenreIds;
  double get ratingDisplay => ratingValue / 10;

  // ===== Lifecycle Methods ===== //

  @override
  void initState() {
    super.initState();
    // Initialize with provided values or defaults
    selectedCategoryId = widget.initialCategoryId ?? 0;
    ratingValue = widget.initialRatingValue ?? 0.0;
    selectedGenreIds =
        widget.initialSelectedGenreIds != null
            ? Set<int>.from(widget.initialSelectedGenreIds!)
            : <int>{};
  }

  // ===== Class Methods ===== //

  bool shouldShowRating(int categoryId) => true;

  void toggleGenre(int genreId, bool selected) {
    setState(() {
      if (selected) {
        selectedGenreIds.add(genreId);
      } else {
        selectedGenreIds.remove(genreId);
      }
    });
  }

  void resetFilters() {
    setState(() {
      selectedCategoryId = 0;
      ratingValue = 0.0;
      selectedGenreIds.clear();
    });
  }

  void applyFilters() {
    // Convert selected genre IDs to genre names
    final selectedGenreNames =
        selectedGenreIds
            .map(
              (genreId) =>
                  genres
                      .firstWhere(
                        (g) => g['id'] == genreId,
                        orElse: () => <String, dynamic>{'id': -1, 'name': ''},
                      )['name']
                      ?.toString(),
            )
            .where((name) => name != null && name.isNotEmpty)
            .cast<String>()
            .toList();

    final filters = <String, dynamic>{
      'genreNames': selectedGenreNames,
      'categoryId': selectedCategoryId.toString(),
      'minRating': ratingDisplay.toStringAsFixed(1),
    };

    Navigator.pop(context, filters);
  }

  // ===== Class Widgets ===== //

  Widget _buildGenreFilters() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: genres.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final genre = genres[index];
          final isSelected = selectedGenreIds.contains(genre['id']);

          return ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: FilterChip(
                selected: isSelected,
                label: Text(
                  genre['name'],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w500 : FontWeight.normal,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                onSelected: (selected) => toggleGenre(genre['id'], selected),
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                selectedColor: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.2),
                checkmarkColor: Theme.of(context).colorScheme.primary,
                side: BorderSide(
                  color:
                      isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Center(
      child: SizedBox(
        height: 48,
        child: Align(
          alignment: Alignment.center,
          child: ListView.separated(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            physics: ClampingScrollPhysics(),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = selectedCategoryId == category['id'];
              return ChoiceChip(
                label: Text(
                  category['name'],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                onSelected:
                    (_) => setState(() => selectedCategoryId = category['id']),
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                selectedColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.15),
                labelStyle: TextStyle(
                  color:
                      isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRatingFilter() {
    return Column(
      children: [
        // Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Theme.of(context).colorScheme.primary,
            inactiveTrackColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.3),
            trackHeight: 4,
            thumbColor: Theme.of(context).colorScheme.primaryContainer,
            overlayColor: Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.2),
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 8),
            valueIndicatorColor: Theme.of(context).colorScheme.primary,
            valueIndicatorTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: Slider(
            value: ratingValue,
            min: 0.0,
            max: 10.0,
            divisions: 20,
            label: ratingValue.toString(),
            onChanged: (value) => setState(() => ratingValue = value),
          ),
        ),

        // Padding
        const SizedBox(height: 16),

        // Rating display
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: gradientContainer(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star_rounded,
                size: 20,
                color:
                    ratingValue > 0
                        ? Colors.amber
                        : Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(width: 8),
              Text(
                ratingValue.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Reset button
        Expanded(
          child: OutlinedButton(
            onPressed: resetFilters,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              'Reset Filters',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        // Padding
        const SizedBox(width: 12),

        // Apply button
        Expanded(
          child: Container(
            decoration: buttonDecoration(context),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: applyFilters,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Center(
                    child: Text(
                      'Apply Filters',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===== Build method ===== //

  @override
  Widget build(BuildContext context) {
    return Container(
      // Theme
      decoration: BoxDecoration(
        gradient: gradientBackground(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),

      // Padding
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),

      // Content
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Padding
          const SizedBox(height: 20),

          // Section titles
          sectionHeader(
            context,
            "Filters",
            "Filter by ${genresTitle.toLowerCase()}, ${categoriesTitle.toLowerCase()}, and rating",
          ),

          // Genre filters
          _buildGenreFilters(),

          // Padding
          const SizedBox(height: 8),

          // Category selector
          _buildCategorySelector(),

          // Padding
          const SizedBox(height: 8),

          // Rating filter (conditionally shown)
          if (shouldShowRating(selectedCategoryId)) ...[_buildRatingFilter()],

          // Padding
          const SizedBox(height: 24),

          // Action buttons (fixed at bottom)
          _buildActionButtons(),

          // Padding
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
