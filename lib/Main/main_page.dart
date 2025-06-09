// ==================== Main Page ==================== //

// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/Games/games_main.dart';
import 'package:omnirate/Shows/shows_main.dart';
import 'package:omnirate/Home/home_main.dart';
import 'package:omnirate/Movies/movies_main.dart';
import 'package:omnirate/Main/animated_bar.dart';

// ========== Main Page Class ========== //

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  // ===== Class Variables ===== //

  // Index of the currently selected page
  int _currentIndex = 3;

  // Instances of the main pages
  final GamesMainPage _playMainPage = GamesMainPage();
  final ShowsMainPage _showsMainPage = ShowsMainPage();
  final HomeMainPage _homeMainPage = HomeMainPage();
  final MoviesMainPage _moviesMainPage = MoviesMainPage();
  // final AssistantMainPage _assistantMainPage = AssistantMainPage();

  // ===== Class Widgets ===== //

  // Switches between main pages
  Widget pageSwitcher() {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: IndexedStack(
        index: _currentIndex,
        children: [
          _playMainPage,
          _showsMainPage,
          _moviesMainPage,
          _homeMainPage,
        ],
      ),
    );
  }

  // Custom navigation bar implementation
  Widget navigationBar() {
    return AnimatedBottomBar(
      items: const [
        AnimatedBottomBarItem(
          icon: Icons.videogame_asset_rounded,
          title: 'Games',
        ),
        AnimatedBottomBarItem(icon: Icons.tv, title: 'Shows'),
        AnimatedBottomBarItem(icon: Icons.movie, title: 'Movies'),
        AnimatedBottomBarItem(icon: Icons.home, title: 'Home'),
        // AnimatedBottomBarItem(icon: Icons.assistant, title: 'Assistant'),
      ],
      initialIndex: _currentIndex,
      onTabSelected: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
    );
  }

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          pageSwitcher(),
          Positioned(left: 0, right: 0, bottom: 20, child: navigationBar()),
        ],
      ),
    );
  }
}
