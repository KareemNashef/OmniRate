// Flutter imports
import 'dart:math';

import 'package:flutter/material.dart';

// Local imports

// ========== Games filter page ========== //

class GamesFilterPage extends StatefulWidget {
  const GamesFilterPage({Key? key}) : super(key: key);

  @override
  State<GamesFilterPage> createState() => _GamesFilterPageState();
}

class _GamesFilterPageState extends State<GamesFilterPage> {
  // ===== Class variables =====

  final List<Map<String, dynamic>> genres = [
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

  int _selectedCategoryId = 0;
  final List<Map<String, dynamic>> categories = [
    {"id": 0, "name": "Base Game"},
    {"id": 1, "name": "DLC"},
    {"id": 2, "name": "Expansion"},
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
        entryTitle("Categories:"),
        categoriesRow(),

        // Rating filter
        entryTitle("Minimum Rating:"),
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
