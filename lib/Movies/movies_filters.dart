// ==================== Movie Filter Page ==================== //

// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/BasePages/base_filter.dart';

class MoviesFilterPage extends FilterModalBase {
  // ===== Constructor ===== //
  const MoviesFilterPage({
    super.key,
    super.initialCategoryId,
    super.initialRatingValue,
    super.initialSelectedGenreIds,
  });

  @override
  State<MoviesFilterPage> createState() => _MoviesFilterPageState();
}

class _MoviesFilterPageState extends FilterModalBaseState<MoviesFilterPage> {
  @override
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

  @override
  final List<Map<String, dynamic>> categories = [
    {"id": 0, "name": "Available now"},
    {"id": 1, "name": "Upcoming"},
  ];

  @override
  String get categoriesTitle => "Availability:";

  @override
  bool shouldShowRating(int categoryId) => categoryId == 0;
}
