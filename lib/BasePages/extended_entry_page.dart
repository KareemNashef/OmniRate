// ==================== Extended Entry Page ==================== //

// Flutter imports
import 'package:flutter/material.dart';
import 'package:omnirate/BasePages/comment_page.dart';
import 'package:omnirate/Database/model_entry.dart';
import 'package:omnirate/Database/model_game.dart';
import 'package:omnirate/Database/model_movie.dart';
import 'package:omnirate/Database/model_show.dart';
import 'package:omnirate/Games/game_entry.dart';

// Local imports
import 'package:omnirate/Movies/movie_entry.dart';
import 'package:omnirate/Shows/show_entry.dart';
import 'package:omnirate/Main/animated_bar.dart';

// ========== Extended Entry Page Class ========== //

class ExtendedEntryPage extends StatefulWidget {
  // ===== Input Variables ===== //
  final MediaEntry inEntry;

  // ===== Constructor ===== //
  const ExtendedEntryPage({super.key, required this.inEntry});

  @override
  State<ExtendedEntryPage> createState() => ExtendedEntryPageState();
}

class ExtendedEntryPageState extends State<ExtendedEntryPage> {
  // ===== Class Variables ===== //

  // Index of the currently selected page
  int _currentIndex = 0;

  // Instances of the pages
  late final Widget entryMainPage;
  late final Widget entryFeedPage;

  // ===== Lifecycle Functions ===== //

  @override
  void initState() {
    super.initState();
    entryMainPage = switch (widget.inEntry.mediaType) {
      MediaType.game => GameEntry(inEntry: widget.inEntry as Game),
      MediaType.show => ShowEntry(inEntry: widget.inEntry as Show),
      MediaType.movie => MovieEntry(inEntry: widget.inEntry as Movie),
    };

    // TODO
    entryFeedPage = CommentPage(inEntry: widget.inEntry);
  }

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
        children: [entryMainPage, entryFeedPage],
      ),
    );
  }

  // Custom navigation bar implementation
  Widget navigationBar() {
    final icon = switch (widget.inEntry.mediaType) {
      MediaType.game => Icons.videogame_asset_rounded,
      MediaType.movie => Icons.movie,
      MediaType.show => Icons.tv,
    };
    final title = switch (widget.inEntry.mediaType) {
      MediaType.game => 'Game',
      MediaType.movie => 'Movie',
      MediaType.show => 'Show',
    };

    return AnimatedBottomBar(
      items: [
        AnimatedBottomBarItem(icon: icon, title: title),
        const AnimatedBottomBarItem(icon: Icons.comment, title: 'Feed'),
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
