// Flutter imports
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

// Local imports
import 'package:omnirate/Shared/firebase_service.dart';
import 'package:omnirate/Shared/utils.dart';
import 'package:omnirate/Main/main_page.dart';
import 'package:omnirate/Shared/providers.dart';
import 'package:omnirate/Shared/user_data.dart';

// ========== Helper Vars ========== //

enum WelcomeState { splash, login, onboarding, themeSelection }

// ========== Welcome page base ========== //

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
  late final PageController _pageController;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  // State management
  WelcomeState _currentState = WelcomeState.splash;

  // Form controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final Set<int> _selectedGameGenres = {};
  final Set<int> _selectedShowGenres = {};
  final Set<int> _selectedMovieGenres = {};

  // Loading state variables
  bool _isSigningIn = false;
  bool _isSigningUp = false;

  // Theme selection
  Color? _selectedColor;

  // ===== Class Methods ===== //

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

  void _navigateToState(WelcomeState newState) {
    setState(() {
      _currentState = newState;
    });
    _pageController.animateToPage(
      newState.index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void _handleSignIn() async {
    // Show loading indicator
    if (_isSigningIn) return;
    setState(() {
      _isSigningIn = true;
    });

    try {
      // Get the input values
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Check if any of the fields are empty
      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Please fill in all fields')));
        return;
      }

      // Attempt to sign in
      final firebaseService = FirebaseService();
      final user = await firebaseService.signIn(email, password);

      // If successful, load user data and navigate to the main page
      if (user != null) {
        final data = await firebaseService.loadUserData();
        if (data != null) {
          final box = await Hive.openBox<UserData>('userBox');
          await box.put('user', data);
        }

        await _setSeenWelcome();
        _goToMainPage();
      }
    }
    // If an error occurs, show a snackbar
    catch (e) {
      String message = 'Sign in failed.';
      if (e is FirebaseAuthException) {
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
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        // Hide loading indicator
        setState(() {
          _isSigningIn = false;
        });
      }
    }
  }

  void _handleSignUp() {
    _navigateToState(WelcomeState.onboarding);
  }

  void _handleOnboardingComplete() async {
    // Show loading indicator
    if (_isSigningUp) return;
    setState(() {
      _isSigningUp = true;
    });

    try {
      // Get the input values
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final username = _usernameController.text.trim();

      // Check if any of the fields are empty
      if (email.isEmpty || password.isEmpty || username.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Please fill in all fields')));
        return;
      }

      // Attempt to sign up
      final firebaseService = FirebaseService();
      final user = await firebaseService.signUp(email, password, username);

      if (user != null) {
        // Save user data to Hive
        final box = await Hive.openBox<UserData>('userBox');
        final userData = UserData(
          userName: username,
          email: email,
          listGames: {},
          listShows: {},
          listMovies: {},
        );
        await box.put('user', userData);

        // Save user data to Firestore
        await firebaseService.saveUserData(userData);

        _navigateToState(WelcomeState.themeSelection);
      }
    }
    // If an error occurs, show a snackbar
    catch (e) {
      String message = 'Sign up failed.';
      if (e is FirebaseAuthException) {
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
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        // Hide loading indicator
        setState(() {
          _isSigningUp = false;
        });
      }
    }
  }

  void _handleThemeSelectionComplete() async {
    if (_selectedColor != null) {
      context.read<ThemeProvider>().setMainColor(_selectedColor!);
    }
    await _setSeenWelcome();
    _goToMainPage();
  }

  Future<void> _setSeenWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenWelcome', true);
  }

  void _goToMainPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => MainPage()),
    );
  }

  @override
  void dispose() {
    _scrollTimer.cancel();
    _gamesController.dispose();
    _showsController.dispose();
    _moviesController.dispose();
    _pageController.dispose();
    _fadeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  // ===== Class Widgets ===== //

  // Scrolling background
  Widget _buildImageColumn(List<String> paths, ScrollController controller) {
    return Expanded(
      child: ShaderMask(
        shaderCallback:
            (rect) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black, Colors.transparent],
              stops: [0, 0.5, 1],
            ).createShader(rect),
        blendMode: BlendMode.dstIn,
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
      ),
    );
  }

  // Splash content
  Widget _buildSplashContent() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/settings/logo.png', height: 200),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              "All your favorite games, shows, and movies. Rated, tracked, and organized in one place!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: () => _navigateToState(WelcomeState.login),
                child: const Text(
                  "Get Started",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Login content
  Widget _buildLoginContent() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Welcome back section
            Column(
              children: [
                Image.asset('assets/settings/logo.png', height: 120),
                const SizedBox(height: 24),
                Text(
                  "Welcome!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Sign in to continue",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),

            // Padding
            const SizedBox(height: 40),

            // Email field
            Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 0.95),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _emailController,
                style: TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
              ),
            ),

            // Padding
            const SizedBox(height: 16),

            // Password field
            Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 0.95),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
              ),
            ),

            // Padding
            const SizedBox(height: 24),

            // Sign in button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: _isSigningIn ? null : _handleSignIn,
                child:
                    _isSigningIn
                        ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        )
                        : const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),

            // Padding
            const SizedBox(height: 16),

            // Sign up prompt
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: TextStyle(color: Colors.white70),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _handleSignUp,
                  child: Text(
                    'Sign up',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Filters row
  Widget _buildFiltersRow(
    List<Map<String, dynamic>> genres,
    Set<int> selectedSet,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children:
            genres.map((genre) {
              final bool isSelected = selectedSet.contains(genre['id']);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(
                    genre['name'],
                    style: TextStyle(
                      color:
                          isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  backgroundColor: Color.fromRGBO(255, 255, 255, 0.1),
                  selectedColor: Theme.of(context).colorScheme.primary,
                  checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                  side: BorderSide(
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Color.fromRGBO(255, 255, 255, 0.3),
                  ),
                  onSelected: (selected) {
                    setState(() {
                      selected
                          ? selectedSet.add(genre['id'])
                          : selectedSet.remove(genre['id']);
                    });
                  },
                ),
              );
            }).toList(),
      ),
    );
  }

  // Onboarding content
  Widget _buildOnboardingContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Image.asset('assets/settings/logo.png', height: 80),
                const SizedBox(height: 16),
                Text(
                  'Welcome aboard!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We just need a little info to get started.',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Email field
          Text(
            'Email',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 255, 255, 0.95),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _emailController,
              style: TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Email',
                hintStyle: TextStyle(color: Colors.grey[600]),
                floatingLabelBehavior: FloatingLabelBehavior.never,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
              ),
            ),
          ),

          // Padding
          const SizedBox(height: 16),

          // Password field
          Text(
            'Password',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 255, 255, 0.95),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _passwordController,
              obscureText: true,
              style: TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: TextStyle(color: Colors.grey[600]),
                floatingLabelBehavior: FloatingLabelBehavior.never,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
              ),
            ),
          ),

          // Padding
          const SizedBox(height: 16),

          // Username field
          Text(
            'Username',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 255, 255, 0.95),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: _usernameController,
              style: TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Enter your username',
                hintStyle: TextStyle(color: Colors.grey[600]),
                floatingLabelBehavior: FloatingLabelBehavior.never,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Game genres
          Text(
            'What game genres do you like?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _buildFiltersRow(genresGames, _selectedGameGenres),
          const SizedBox(height: 24),

          // Show genres
          Text(
            'What show genres do you like?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _buildFiltersRow(genresShows, _selectedShowGenres),
          const SizedBox(height: 24),

          // Movie genres
          Text(
            'What movie genres do you like?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _buildFiltersRow(genresMovies, _selectedMovieGenres),
          SizedBox(height: 40),

          // Continue button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
              ),
              onPressed: _isSigningUp ? null : _handleOnboardingComplete,
              child:
                  _isSigningUp
                      ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      )
                      : const Text(
                        'Complete Setup',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
            ),
          ),
          const SizedBox(height: 16),

          // Back to login
          Center(
            child: TextButton(
              onPressed: () => _navigateToState(WelcomeState.login),
              child: Text(
                'Already have an account? Sign in',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Theme selection
  Widget _buildThemeSelectionContent() {
    final List<Color> colors = [
      Color(0xFFEF5350), // Red
      Color(0xFF66BB6A), // Green
      Color(0xFF42A5F5), // Blue
      Color(0xFFFFEB3B), // Yellow
      Color(0xFFAB47BC), // Purple
      Color(0xFFFF7043), // Orange
      Color(0xFF26C6DA), // Cyan
    ];

    Widget colorButton(Color color) {
      final bool isSelected = _selectedColor == color;
      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedColor = color;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 280,
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.transparent,
              width: 4,
            ),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: color.withAlpha(128),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                    : null,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 60),

          // Header
          Center(
            child: Column(
              children: [
                Image.asset('assets/settings/logo.png', height: 80),
                const SizedBox(height: 24),
                Text(
                  'Choose Your Style',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pick your favorite accent color',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Color selection
          Column(children: colors.map((color) => colorButton(color)).toList()),

          const SizedBox(height: 40),

          // Continue button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _selectedColor ?? Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
              ),
              onPressed: _handleThemeSelectionComplete,
              child: const Text(
                'Complete Setup',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Skip button
          Center(
            child: TextButton(
              onPressed: _handleThemeSelectionComplete,
              child: Text(
                'Skip - Use Default',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          FadeTransition(
            opacity: _fadeAnimation,
            child: Row(
              children: [
                _buildImageColumn(gamesPaths, _gamesController),
                const SizedBox(width: 16),
                _buildImageColumn(showsPaths, _showsController),
                const SizedBox(width: 16),
                _buildImageColumn(moviesPaths, _moviesController),
              ],
            ),
          ),

          // Background overlay
          Container(color: Color.fromRGBO(0, 0, 0, 0.6)),

          // Page content
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildSplashContent(),
              _buildLoginContent(),
              _buildOnboardingContent(),
              _buildThemeSelectionContent(),
            ],
          ),

          // Back button for login and onboarding
          if (_currentState != WelcomeState.splash)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              child: IconButton(
                onPressed:
                    () => _navigateToState(
                      _currentState == WelcomeState.login
                          ? WelcomeState.splash
                          : _currentState == WelcomeState.onboarding
                          ? WelcomeState.login
                          : WelcomeState.onboarding,
                    ),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shape: const CircleBorder(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
