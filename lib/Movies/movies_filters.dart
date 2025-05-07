// Flutter imports
import 'package:flutter/material.dart';

// Local imports

// ========== Movies filter page ========== //

class MoviesFilterPage extends StatefulWidget {
  const MoviesFilterPage({Key? key}) : super(key: key);

  @override
  State<MoviesFilterPage> createState() => _MoviesFilterPageState();
}

class _MoviesFilterPageState extends State<MoviesFilterPage> {
  // ===== Class variables =====

  final List<Map<String, dynamic>> genres = [
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

  int _selectedCategoryId = 0;
  final List<Map<String, dynamic>> categories = [
    {"id": 0, "name": "Available now"},
    {"id": 1, "name": "Upcoming"},
  ];

  double _ratingValue = 0.0; // Default rating
  // ===== Class Widgets =====

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

  // Filters row
  Widget filtersRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(8),
      child: Row(
        children:
            genres.map((filter) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: FilterChip(
                  label: Text(filter['name']),
                  onSelected: (_) {},
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
                label: Text(category['name'], style: TextStyle(fontSize: 13)),
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
          Slider(
            value: _ratingValue,
            min: 0,
            max: 100,
            divisions: 20,
            label: _ratingValue.toStringAsFixed(1),
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
            _selectedCategoryId = 0; // Reset selected category
            // Add logic to reset other filters (e.g., rating) if needed
          });
        },
        child: Text('Reset Filters'),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 50), // Full width button
        ),
      ),
    );
  }

  // Apply button
  Widget applyButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          // Logic to apply the filters
          // You can use the selected category, rating, and other filters
        },
        child: Text('Apply Filters'),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 50), // Full width button
        ),
      ),
    );
  }

  // ===== Build method =====

  // ===== Updated Build Method with Filter Widgets =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Remove the back arrow
        automaticallyImplyLeading: false,

        // Set the height
        toolbarHeight: 20,

        title: Center(
          child: Container(
            width: 100, // Set width as needed
            height: 4, // Set thickness
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12), // Circular effect
            ),
          ),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Genre filter
          entryTitle("Genres:"),
          filtersRow(),

          // Category filter
          entryTitle("Availability:"),
          categoriesRow(),

          // Rating filter
          if (_selectedCategoryId == 0) 
          entryTitle("Minimum Rating:"),
          if (_selectedCategoryId == 0)
          ratingFilter(),

          // Reset filters button
          resetFiltersButton(),

          // Apply button at the bottom
          applyButton(),
        ],
      ),
    );
  }
}
