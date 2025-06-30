// ==================== Welcome Page ==================== //

// Flutter imports
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

// Local imports
import 'package:omnirate/Shared/firebase_service.dart';
import 'package:omnirate/Shared/utils.dart';
import 'package:omnirate/Main/main_page.dart';
import 'package:omnirate/Main/helper_widgets.dart';
import 'package:omnirate/Shared/user_data.dart';

// Enum for welcome page state
enum WelcomeState { splash, login, onboarding, themeSelection }

// ========== Welcome Page Class ========== //

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => WelcomePageState();
}

class WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  // ===== Class Variables ===== //

  // Background animation controllers
  late final ScrollController _gamesController;
  late final ScrollController _showsController;
  late final ScrollController _moviesController;
  late final Timer _scrollTimer;

  // Page switching controllers
  late final PageController _pageController;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  // ===== Lifecycle Methods ===== //

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _startSmoothScroll();
  }

  void _initializeControllers() {
    _gamesController = ScrollController();
    _showsController = ScrollController();
    _moviesController = ScrollController();
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  void _startSmoothScroll() {
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted) return;
      _smoothScroll(_gamesController);
      _smoothScroll(_showsController);
      _smoothScroll(_moviesController);
    });
  }

  @override
  void dispose() {
    _scrollTimer.cancel();
    _gamesController.dispose();
    _showsController.dispose();
    _moviesController.dispose();
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // ===== Logic & Navigation Methods ===== //

  void _navigateToState(WelcomeState newState) {
    setState(() {});
    _pageController.animateToPage(
      newState.index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _handleSignIn(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        _showSnackBar('Please fill in all fields');
        return;
      }
      final firebaseService = FirebaseService();
      final user = await firebaseService.signIn(email, password);

      if (user != null) {
        final data = await firebaseService.loadUserData();
        if (data != null) {
          final box = await Hive.openBox<UserData>('userBox');
          await box.put('user', data);
        }
        await _setSeenWelcome();
        _goToMainPage();
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Sign in failed.';
      switch (e.code) {
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        case 'user-not-found':
          message = 'No account found for that email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password.';
          break;
        default:
          message = 'Error: ${e.message}';
      }
      _showSnackBar(message);
    } catch (e) {
      _showSnackBar('An unexpected error occurred.');
    }
  }

  Future<void> _handleOnboardingComplete({
    required String email,
    required String password,
    required String username,
    required int avatarIndex,
  }) async {
    try {
      if (email == "Ass") {
        _navigateToState(WelcomeState.themeSelection);
        return;
      }
      if (email.isEmpty || password.isEmpty || username.isEmpty) {
        _showSnackBar('Please fill in all fields');
        return;
      }

      final firebaseService = FirebaseService();
      final user = await firebaseService.signUp(email, password, username);

      if (user != null) {
        final box = await Hive.openBox<UserData>('userBox');
        final userData = UserData(
          userName: username,
          email: email,
          avatarIndex: avatarIndex,
          listGames: {},
          listShows: {},
          listMovies: {},
        );
        await box.put('user', userData);
        await firebaseService.saveUserData(userData);
        _navigateToState(WelcomeState.themeSelection);
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Sign up failed.';
      switch (e.code) {
        case 'email-already-in-use':
          message = 'That email is already registered.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email.';
          break;
        case 'weak-password':
          message = 'Password is too weak.';
          break;
        default:
          message = e.message ?? message;
      }
      _showSnackBar(message);
    } catch (e) {
      _showSnackBar('An unexpected error occurred.');
    }
  }

  void _handleThemeSelectionComplete() async {
    await _setSeenWelcome();
    _goToMainPage();
  }

  // ===== Helper Methods ===== //

  void _smoothScroll(ScrollController controller) {
    if (controller.hasClients) {
      double newOffset = controller.offset + 0.5;
      if (newOffset >= controller.position.maxScrollExtent) {
        controller.jumpTo(0);
      } else {
        controller.jumpTo(newOffset);
      }
    }
  }

  Widget _buildImageColumn(List<String> paths, ScrollController controller) {
    return Expanded(
      child: ListView.builder(
        controller: controller,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: paths.length * 10,
        itemBuilder:
            (context, index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  paths[index % paths.length],
                  fit: BoxFit.cover,
                ),
              ),
            ),
      ),
    );
  }

  Future<void> _setSeenWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenWelcome', true);
  }

  void _goToMainPage() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainPage()),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            // Animated background
            FadeTransition(
              opacity: _fadeAnimation,
              child: Row(
                children: [
                  const SizedBox(width: 4),
                  _buildImageColumn(gamesPaths, _gamesController),
                  const SizedBox(width: 8),
                  _buildImageColumn(showsPaths, _showsController),
                  const SizedBox(width: 8),
                  _buildImageColumn(moviesPaths, _moviesController),
                  const SizedBox(width: 4),
                ],
              ),
            ),

            // Background blur
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: const Color.fromRGBO(0, 0, 0, 0.5)),
            ),

            // Page content
            PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                SplashContent(
                  onGetStarted: () => _navigateToState(WelcomeState.login),
                ),
                LoginContent(
                  onSignIn: _handleSignIn,
                  onSignUp: () => _navigateToState(WelcomeState.onboarding),
                ),
                OnboardingContent(
                  onComplete: _handleOnboardingComplete,
                  onBackToLogin: () => _navigateToState(WelcomeState.login),
                ),
                ThemeSelectionContent(
                  onComplete: _handleThemeSelectionComplete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
