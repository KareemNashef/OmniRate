// ==================== About Page ==================== //

// Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omnirate/Database/database_helper.dart';
import 'package:omnirate/Shared/utils.dart';
import 'dart:math';

// ========== About Page Class ========== //

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;
  List<String> _easterEggs = [];
  String _currentEasterEgg = "";
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );
    _loadEasterEggs();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _loadEasterEggs() async {
    try {
      final String content = await rootBundle.loadString(
        'assets/settings/egg.txt',
      );
      setState(() {
        _easterEggs =
            content
                .split('\n')
                .where((line) => line.trim().isNotEmpty)
                .toList();
      });
    } catch (e) {
      // Fallback easter eggs if file doesn't exist
      setState(() {
        _easterEggs = [
          "🎮 Game on!",
          "🍿 Popcorn time!",
          "📺 Binge mode activated!",
          "⭐ Five stars!",
          "🎬 Action!",
          "🎯 Perfect score!",
        ];
      });
    }
  }

  void _triggerEasterEgg() {
    if (_easterEggs.isNotEmpty) {
      setState(() {
        _currentEasterEgg = _easterEggs[_random.nextInt(_easterEggs.length)];
      });
      _rotationController.forward().then((_) {
        _rotationController.reset();
        // Clear easter egg after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _currentEasterEgg = "";
            });
          }
        });
      });
    }
  }

  // ===== Class Widgets ===== //

  Widget _buildAppLogo(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _triggerEasterEgg,
          child: AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value * 2 * pi,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha(64),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/settings/egg.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (_currentEasterEgg.isNotEmpty) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: AnimatedOpacity(
              opacity: _currentEasterEgg.isNotEmpty ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(32),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withAlpha(64),
                  ),
                ),
                child: Text(
                  _currentEasterEgg,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: containerDecoration(context),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(32),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(180),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSourceCard(
    BuildContext context, {
    required String name,
    required String description,
    required String url,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: containerDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            url,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    return Container(
      // Background
      decoration: BoxDecoration(gradient: gradientBackground(context)),

      // Foreground
      child: Scaffold(
        backgroundColor: Colors.transparent,

        // Body
        body: Container(
          decoration: BoxDecoration(gradient: gradientBackground(context)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 100, bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App Logo and Name
                _buildAppLogo(context),
                const SizedBox(height: 24),

                Text(
                  "OmniRate",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  "Your Ultimate Entertainment Tracker",
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(180),
                  ),
                ),

                const SizedBox(height: 32),

                // Features Section
                sectionHeader(
                  context,
                  "What OmniRate Does",
                  "Track, discover, and organize your entertainment",
                ),
                const SizedBox(height: 16),

                _buildInfoCard(
                  context,
                  icon: Icons.videogame_asset,
                  title: "Video Games",
                  description:
                      "Discover new games, track your progress, and build your gaming library",
                ),

                _buildInfoCard(
                  context,
                  icon: Icons.tv,
                  title: "TV Shows",
                  description:
                      "Keep track of episodes, seasons, and your favorite series",
                ),

                _buildInfoCard(
                  context,
                  icon: Icons.movie,
                  title: "Movies",
                  description:
                      "Rate movies, create watchlists, and never forget what to watch next",
                ),

                _buildInfoCard(
                  context,
                  icon: Icons.list_alt,
                  title: "Personal Lists",
                  description:
                      "Organize your entertainment with custom lists and progress tracking",
                ),

                const SizedBox(height: 32),

                // Data Sources Section
                sectionHeader(
                  context,
                  "Powered By",
                  "Quality data from trusted sources",
                ),
                const SizedBox(height: 16),

                _buildDataSourceCard(
                  context,
                  name: "IGDB",
                  description:
                      "Internet Game Database - Comprehensive video game information and metadata",
                  url: "api.igdb.com",
                ),

                _buildDataSourceCard(
                  context,
                  name: "TMDB",
                  description:
                      "The Movie Database - Extensive movie and TV show data",
                  url: "api.themoviedb.org",
                ),

                const SizedBox(height: 32),

                // Version Info
                GestureDetector(
                  onDoubleTap: () {
                    HiveHelper.clearAllData();
                  },

                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: containerDecoration(context),
                    child: Text(
                      "Made with ❤️ for entertainment enthusiasts",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(160),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
