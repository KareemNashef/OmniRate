// ==================== Main Page ==================== //

// Flutter imports
import 'package:flutter/material.dart';
import 'package:omnirate/Feed/feed_page.dart';

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

class MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  // ===== Class Variables ===== //

  // Index of the currently selected page and the previous page
  int _currentIndex = 0;

  // Instances of the main pages
  final HomeMainPage _homeMainPage = HomeMainPage();
  final GamesMainPage _playMainPage = GamesMainPage();
  final ShowsMainPage _showsMainPage = ShowsMainPage();
  final MoviesMainPage _moviesMainPage = MoviesMainPage();
  final FeedPage _feedPage = FeedPage();

  // ===== Class Widgets ===== //

  // Switches between main pages
  Widget pageSwitcher() {
    return IndexedStack(
      index: _currentIndex,
      children: [
        _homeMainPage,
        _playMainPage,
        _showsMainPage,
        _moviesMainPage,
        _feedPage,
      ],
    );
  }

  // Custom navigation bar implementation
  Widget navigationBar() {
    return AnimatedBottomBar(
      items: const [
        AnimatedBottomBarItem(icon: Icons.home, title: 'Home'),
        AnimatedBottomBarItem(
          icon: Icons.videogame_asset_rounded,
          title: 'Games',
        ),
        AnimatedBottomBarItem(icon: Icons.tv, title: 'Shows'),
        AnimatedBottomBarItem(icon: Icons.movie, title: 'Movies'),
        AnimatedBottomBarItem(icon: Icons.group, title: 'Social'),
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
