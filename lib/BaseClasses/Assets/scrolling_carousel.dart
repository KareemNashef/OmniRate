// // Flutter imports
// import 'dart:async';
// import 'package:flutter/material.dart';

// // Local imports
// import 'package:omnirate/Games/game_entry.dart';
// import 'package:omnirate/Shows/show_entry.dart';
// import 'package:omnirate/Movies/movie_entry.dart';
// import 'package:omnirate/BaseClasses/Assets/animated_entry.dart';

// class AutoScrollCarousel extends StatefulWidget {
//   final String inType;
//   final List<String> inPaths, inTitles;
//   final List<String> inRatings, inArtworks;

//   const AutoScrollCarousel({
//     super.key,
//     required this.inType,
//     required this.inPaths,
//     required this.inTitles,
//     this.inRatings = const [],
//     this.inArtworks = const [],
//   });

//   @override
//   State<AutoScrollCarousel> createState() => _AutoScrollCarouselState();
// }

// class _AutoScrollCarouselState extends State<AutoScrollCarousel> {
//   late final PageController _controller;
//   late final Timer _timer;
//   int _currentPage = 0;

//   @override
//   void initState() {
//     super.initState();
//     _controller = PageController();
//     _timer = Timer.periodic(Duration(seconds: 10), (_) {
//       if (_controller.hasClients) {
//         _currentPage = (_currentPage + 1) % widget.inTitles.length;
//         _controller.animateToPage(
//           _currentPage,
//           duration: Duration(milliseconds: 500),
//           curve: Curves.easeInOut,
//         );
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 290,
//       child: PageView.builder(
//         controller: _controller,
//         itemCount: widget.inTitles.length,
//         itemBuilder: (context, index) {
//           return GestureDetector(
//             onTap: () {
//               Widget page;
//               switch (widget.inType) {
//                 case "Games":
//                   page = GameEntry(inTitle: widget.inTitles[index]);
//                   break;
//                 case "Shows":
//                   page = ShowEntry();
//                   break;
//                 case "Movies":
//                   page = MovieEntry();
//                   break;
//                 default:
//                   return;
//               }
//               Navigator.push(context, MaterialPageRoute(builder: (_) => page));
//             },
//             child: AnimatedBackgroundCard(
//               inTitle: widget.inTitles[index],
//               inPath: widget.inPaths[index],
//               inRating: widget.inRatings.isNotEmpty ? widget.inRatings[index] : '',
//               inArtwork: widget.inArtworks.isNotEmpty ? widget.inArtworks[index] : '',
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
