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

// ========== Helper Classes ========== //

// Expandable story text widget
class ExpandableText extends StatefulWidget {
  final String label;
  final String content;

  const ExpandableText({required this.label, required this.content, Key? key})
    : super(key: key);

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(fontSize: 16);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          textAlign: TextAlign.justify,
          text: TextSpan(
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
                style: textStyle,
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
