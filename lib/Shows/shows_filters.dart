// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/BaseClasses/base_filter.dart';

class ShowsFilterPage extends BaseFilterPage {
  const ShowsFilterPage({super.key});

  @override
  State<ShowsFilterPage> createState() => _ShowsFilterPageState();
}

class _ShowsFilterPageState extends BaseFilterPageState<ShowsFilterPage> {
  @override
  final List<Map<String, dynamic>> genres = [
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

  @override
  final List<Map<String, dynamic>> categories = [
    {"id": 0, "name": "Available now"},
    {"id": 1, "name": "Upcoming"},
  ];
  
  @override
  String get categoriesTitle => "Categories:";
  
  @override
  bool shouldShowRating(int categoryId) => categoryId == 0;
}