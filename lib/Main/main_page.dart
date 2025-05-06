// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:omnirate/1_Games/games_main.dart';
import 'package:omnirate/2_Shows/shows_main.dart';
import 'package:omnirate/3_Home/home_main.dart';
import 'package:omnirate/4_Movies/movies_main.dart';
import 'package:omnirate/5_Assistant/assistant_main.dart';
import 'package:omnirate/Main/navigation_bar.dart';

// ========== Main page ========== //

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  // ===== Class Variables ===== //

  // Index of the currently selected page
  int _currentIndex = 2;

  // Instances of the main pages
  final GamesMainPage _playMainPage = GamesMainPage();
  final ShowsMainPage _showsMainPage = ShowsMainPage();
  final HomeMainPage _homeMainPage = HomeMainPage();
  final MoviesMainPage _moviesMainPage = MoviesMainPage();
  final AssistantMainPage _assistantMainPage = AssistantMainPage();

  // ===== Class Widgets ===== //

  // Switches between main pages
  Widget pageSwitcher() {
    return AnimatedSwitcher(
      // Set a fade transition
      duration: Duration(milliseconds: 200),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },

      // Switch between pages
      child: _getPageForIndex(),
    );
  }

  // Returns the main page for the current index
  Widget _getPageForIndex() {
    switch (_currentIndex) {
      case 0:
        return _playMainPage;
      case 1:
        return _showsMainPage;
      case 2:
        return _homeMainPage;
      case 3:
        return _moviesMainPage;
      case 4:
        return _assistantMainPage;
      default:
        return _homeMainPage;
    }
  }

  // Custom navigation bar implementation
  Widget navigationBar() {
    return AnimatedNavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (int index) {
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
          Positioned(left: 0, right: 0, bottom: 32, child: navigationBar()),
        ],
      ),
    );
  }
}
