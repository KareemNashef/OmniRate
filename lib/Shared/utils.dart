// Flutter imports
import 'package:flutter/material.dart';

// ========== Debug global variables ========== //
List<String> gamesList = [
  "The Witcher 3: Wild Hunt",
  "The Elder Scrolls IV: Oblivion Remastered",
  "Clair Obscur: Expedition 33",
  "Drop Duchy",
  "Deadzone: Rogue",
  "Baldur's Gate 3",
  "Mass Effect Trilogy",
  "The Legend of Zelda: Tears of the Kingdom",
  "Elden Ring",
  "R.E.P.O.",
  "Inzoi",
  "Assassin's Creed Shadows",
  "Schedule I",
];

List<String> gamesPaths = [
  "assets/Debug/Games/1.webp",
  "assets/Debug/Games/2.webp",
  "assets/Debug/Games/3.webp",
  "assets/Debug/Games/4.webp",
  "assets/Debug/Games/5.webp",
  "assets/Debug/Games/6.webp",
  "assets/Debug/Games/7.webp",
  "assets/Debug/Games/8.webp",
  "assets/Debug/Games/9.webp",
  "assets/Debug/Games/10.webp",
  "assets/Debug/Games/11.webp",
  "assets/Debug/Games/12.webp",
  "assets/Debug/Games/13.webp",
];

List<String> showsList = [
  "Law & Order: Special Victims Unit",
  "The Eternaut",
  "The Flash",
  "Diners, Drive-Ins and Dives",
  "The Bold and the Beautiful",
  "Tokyo Revengers",
  "WWE NXT",
  "The Studio",
  "Breaking Bad",
  "Arcane",
  "Frieren: Beyond Journey's End",
  "Adventure Time: Fionna & Cake",
  "The Last of Us",
];

List<String> showsPaths = [
  "assets/Debug/Shows/1.webp",
  "assets/Debug/Shows/2.webp",
  "assets/Debug/Shows/3.webp",
  "assets/Debug/Shows/4.webp",
  "assets/Debug/Shows/5.webp",
  "assets/Debug/Shows/6.webp",
  "assets/Debug/Shows/7.webp",
  "assets/Debug/Shows/8.webp",
  "assets/Debug/Shows/9.webp",
  "assets/Debug/Shows/10.webp",
  "assets/Debug/Shows/11.webp",
  "assets/Debug/Shows/12.webp",
  "assets/Debug/Shows/13.webp",
];

List<String> moviesList = [
  "The Alto Knights",
  "Havoc",
  "The Shawshank Redemption",
  "The Godfather",
  "Spirited Away",
  "Schindler's List",
  "A Minecraft Movie",
  "Thunderbolts*",
  "Sinners",
  "Drop",
  "The Accountant²",
  "Exterritorial",
  "A Working Man",
];

List<String> moviesPaths = [
  "assets/Debug/Movies/1.webp",
  "assets/Debug/Movies/2.webp",
  "assets/Debug/Movies/3.webp",
  "assets/Debug/Movies/4.webp",
  "assets/Debug/Movies/5.webp",
  "assets/Debug/Movies/6.webp",
  "assets/Debug/Movies/7.webp",
  "assets/Debug/Movies/8.webp",
  "assets/Debug/Movies/9.webp",
  "assets/Debug/Movies/10.webp",
  "assets/Debug/Movies/11.webp",
  "assets/Debug/Movies/12.webp",
  "assets/Debug/Movies/13.webp",
];

// ========== Global variables ========== //

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
      color: Theme.of(context).colorScheme.onSurface,
    ),
            children: [
              TextSpan(
                text: widget.label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
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
