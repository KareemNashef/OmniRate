// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/BaseClasses/base_filter.dart';

class GamesFilterPage extends BaseFilterPage {
  const GamesFilterPage({Key? key}) : super(key: key);

  @override
  State<GamesFilterPage> createState() => _GamesFilterPageState();
}

class _GamesFilterPageState extends BaseFilterPageState<GamesFilterPage> {
  @override
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

  @override
  final List<Map<String, dynamic>> categories = [
    {"id": 0, "name": "Base Game"},
    {"id": 1, "name": "DLC"},
    {"id": 2, "name": "Expansion"},
  ];

  @override
  String get categoriesTitle => "Categories:";
}