// Flutter imports
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:provider/provider.dart';

// Local imports
import 'package:omnirate/Play/play_main.dart';
import 'package:omnirate/Home/home_main.dart';
import 'package:omnirate/Watch/watch_main.dart';
import 'package:omnirate/Shared/providers.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ThemeProvider())],
      child: MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeProvider.mainColor,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeProvider.mainColor,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: themeProvider.themeMode,
      home: Scaffold(body: MainPage()),
    );
  }
}


// Main page of the app
class MainPage extends StatefulWidget {
  MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

// State class for the main page
class _MainPageState extends State<MainPage> {
  // ===== Class Variables ===== //

  // Scrolling indices
  int _currentIndex = 1;
  int _previousIndex = 1;

  // Pages
  final PlayMainPage _playMainPage = PlayMainPage();
  final HomeMainPage _homeMainPage = HomeMainPage();
  final WatchMainPage _watchMainPage = WatchMainPage();

  // ===== Class Methods ===== //

  // ===== Class Widgets ===== //

  // Page switcher
  Widget pageSwitcher() {
    return PageTransitionSwitcher(
      duration: const Duration(milliseconds: 300),
      reverse: _currentIndex < _previousIndex,
      transitionBuilder: (child, animation, secondaryAnimation) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          child: child,
        );
      },
      child: IndexedStack(
        key: ValueKey<int>(_currentIndex), // Important to trigger the switch
        index: _currentIndex,
        children: [_playMainPage, _homeMainPage, _watchMainPage],
      ),
    );
  }

  // Navigation bar
  Widget navigationBar() {
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (int index) {
        setState(() {
          _previousIndex = _currentIndex;
          _currentIndex = index;
        });
      },
      destinations: [
        NavigationDestination(icon: Icon(Icons.gamepad), label: 'Play'),
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.tv), label: 'Watch'),
      ],
    );
  }

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: pageSwitcher(), bottomNavigationBar: navigationBar());
  }
}
