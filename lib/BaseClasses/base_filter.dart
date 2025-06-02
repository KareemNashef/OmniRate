// Flutter imports
import 'package:flutter/material.dart';

// ========== Base Filter Page ========== //

abstract class BaseFilterPage extends StatefulWidget {
  const BaseFilterPage({super.key});
}

abstract class BaseFilterPageState<T extends BaseFilterPage> extends State<T> {
  // ===== Abstract methods that must be implemented by subclasses =====
  List<Map<String, dynamic>> get genres;
  List<Map<String, dynamic>> get categories;
  String get genresTitle => "Genres:";
  String get categoriesTitle => "Categories:";
  String get ratingTitle => "Minimum Rating:";
  bool shouldShowRating(int categoryId) => true; // Default implementation
  
  // ===== Common state variables =====
  int _selectedCategoryId = 0;
  double _ratingValue = 0.0;
  Set<int> _selectedGenreIds = {};
  
  // ===== Common UI widgets =====
  Widget entryTitle(String inTitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        inTitle,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  // Genres filter row with selection logic
  Widget filtersRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: genres.map((filter) {
          final bool isSelected = _selectedGenreIds.contains(filter['id']);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: FilterChip(
              selected: isSelected,
              label: Text(filter['name']),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedGenreIds.add(filter['id']);
                  } else {
                    _selectedGenreIds.remove(filter['id']);
                  }
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // Categories row
  Widget categoriesRow() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        child: SegmentedButton<int>(
          segments: [
            for (var category in categories)
              ButtonSegment<int>(
                value: category['id'],
                label: Text(category['name'], style: const TextStyle(fontSize: 13)),
              ),
          ],
          selected: {_selectedCategoryId},
          onSelectionChanged: (Set<int> selected) {
            setState(() {
              _selectedCategoryId = selected.first;
            });
          },
        ),
      ),
    );
  }

  // Rating filter widget
  Widget ratingFilter() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${(_ratingValue / 10).toStringAsFixed(1)}/10'),
              SizedBox(width: 8),
              Icon(Icons.star, size: 16, color: Colors.amber),
              SizedBox(width: 8),
              Text(_ratingValue == 0 ? 'Any rating' : 'and above'),
            ],
          ),
          Slider(
            value: _ratingValue,
            min: 0,
            max: 100,
            divisions: 20,
            label: (_ratingValue / 10).toStringAsFixed(1),
            onChanged: (double value) {
              setState(() {
                _ratingValue = value;
              });
            },
          ),
        ],
      ),
    );
  }

  // Reset filters button
  Widget resetFiltersButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedCategoryId = 0;
            _ratingValue = 0.0;
            _selectedGenreIds = {};
          });
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Text('Reset Filters'),
      ),
    );
  }

  // Apply button
  Widget applyButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          // Get the selected filters
          final Map<String, dynamic> filters = {
            'categories': _selectedCategoryId,
            'genres': _selectedGenreIds.toList(),
            'rating': _ratingValue,
          };
          
          // Close the bottom sheet and return the filters
          Navigator.pop(context, filters);
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        child: const Text('Apply Filters'),
      ),
    );
  }

  // ===== Base build method =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 20,
        title: Center(
          child: Container(
            width: 100,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Scrollable content area
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Genre filter
                  entryTitle(genresTitle),
                  filtersRow(),

                  // Category filter
                  entryTitle(categoriesTitle),
                  categoriesRow(),

                  // Rating filter (conditionally shown)
                  if (shouldShowRating(_selectedCategoryId)) 
                    entryTitle(ratingTitle),
                  if (shouldShowRating(_selectedCategoryId))
                    ratingFilter(),
                ],
              ),
            ),
          ),
          
          // Action buttons at the bottom
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                resetFiltersButton(),
                const SizedBox(height: 8),
                applyButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}