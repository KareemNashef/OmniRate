// ==================== AI Discovery Page ==================== //

// Flutter imports
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:omnirate/API/igdb_api.dart';
import 'package:omnirate/API/tmdb_api.dart';

// Local imports
import 'package:omnirate/Home/helpers.dart';
import 'package:omnirate/Home/recommendation_card.dart';
import 'package:omnirate/Shared/list_use.dart';
import 'package:omnirate/Database/model_game.dart';
import 'package:omnirate/Database/model_movie.dart';
import 'package:omnirate/Database/model_show.dart';

// ========== AI Discovery Page Class ========== //

// New color constants for the theme
const Color kPrimaryBlue = Color(0xFF667EEA);
const Color kPrimaryPurple = Color(0xFF764BA2);

class AIDiscoveryPage extends StatefulWidget {
  const AIDiscoveryPage({super.key});

  @override
  State<AIDiscoveryPage> createState() => _AIDiscoveryPageState();
}

enum PageState { input, loading, results }

class _AIDiscoveryPageState extends State<AIDiscoveryPage>
    with TickerProviderStateMixin {
  // ===== Class variables ===== //

  // State
  PageState _pageState = PageState.input;

  // Controllers
  final TextEditingController customController = TextEditingController();
  late final AnimationController _sparkleController;
  late final AnimationController _buttonPulseController;
  late final AnimationController _particlesController;

  // Variables
  String? selectedOption;
  List<Particle> particles = [];

  final List<String> predefinedOptions = [
    'Cozy evening',
    'Adventure seeker',
    'Romantic feeling',
    'Family fun time',
  ];

  String geminiOutput = '''
{
  "games": [
    {
      "title": "Minecraft",
      "reason": "Its open-world creativity and cooperative play are perfect for family fun."
    },
    {
      "title": "Overcooked! 2",
      "reason": "Hilarious cooperative cooking chaos that's great for all ages."
    }
  ],
  "shows": [
    {
      "title": "Gravity Falls",
      "reason": "Mysteries, humor, and heartfelt moments make it a fantastic family watch."
    },
    {
      "title": "Bluey",
      "reason": "Charming and imaginative, it's a hit with both kids and adults."
    }
  ],
  "movies": [
    {
      "title": "The Incredibles",
      "reason": "A super-powered family adventure with action and humor for everyone."
    },
    {
      "title": "Paddington 2",
      "reason": "A heartwarming and delightfully funny film with a positive message."
    }
  ]
}
''';

  // Recommendations
  List<Game> recommendedGames = [];
  List<Show> recommendedShows = [];
  List<Movie> recommendedMovies = [];
  List<String> gameReasons = [];
  List<String> showReasons = [];
  List<String> movieReasons = [];

  // ===== Lifecycle Methods ===== //

  @override
  void initState() {
    super.initState();

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _buttonPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
      lowerBound: 0.0,
      upperBound: 8.0,
    )..repeat(reverse: true);

    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    final random = Random();
    for (int i = 0; i < 50; i++) {
      particles.add(
        Particle(
          x: random.nextDouble(),
          size: random.nextDouble() * 2.0 + 1.0,
          opacity: random.nextDouble() * 0.5 + 0.1,
          offset: random.nextDouble(),
        ),
      );
    }
  }

  @override
  void dispose() {
    customController.dispose();
    _sparkleController.dispose();
    _buttonPulseController.dispose();
    _particlesController.dispose();
    super.dispose();
  }
  // ===== Class Methods ===== //

  Future<void> _generateRecommendations() async {
    // Iniate loading
    setState(() => _pageState = PageState.loading);

    String createdPrompt = '''
You are a recommendation engine that suggests highly personalized games, shows, and movies based on a user's mood and viewing habits.

The user chose the following mood: ${selectedOption == 'custom' ? (customController.text.trim().isEmpty ? 'Custom experience (no text entered)' : customController.text.trim()) : (selectedOption ?? 'No option selected')}

Below are the user's lists, each item formatted as:
[Title]_[Rating/10 or 0.0 if not rated]_[Status: Planned, Completed, Dropped, Current]
''';

    // Load user data
    final listGames = await getMediaByType('Games');
    final listShows = await getMediaByType('Shows');
    final listMovies = await getMediaByType('Movies');

    if (listGames.isNotEmpty) {
      createdPrompt += '\nGames:';
      for (final game in listGames) {
        createdPrompt += '\n${game.name}_${game.rating}_${game.status}';
      }
    }
    if (listShows.isNotEmpty) {
      createdPrompt += '\nShows:';
      for (final show in listShows) {
        createdPrompt += '\n${show.name}_${show.rating}_${show.status}';
      }
    }
    if (listMovies.isNotEmpty) {
      createdPrompt += '\nMovies:';
      for (final movie in listMovies) {
        createdPrompt += '\n${movie.name}_${movie.rating}_${movie.status}';
      }
    }

    createdPrompt += '''
\nFormat your reply strictly as JSON:

{
  "games": [
    { "title": "Game Title", "reason": "Short reason..." }
  ],
  "shows": [
    { "title": "Show Title", "reason": "Short reason..." }
  ],
  "movies": [
    { "title": "Movie Title", "reason": "Short reason..." }
  ]
}

Rules:
- Do not include any text outside the JSON.
- Recommend exactly 1–2 items per category.
- Only suggest content not in the user’s list and not marked as Dropped.
- Keep each reason short (max 20 words).
- If the provided lists are empty, recommend trending content.
''';

    // TODO: SEND TO GEMINI AND GET THE RESPONSE IN geminiOutput

    // Decode the response
    final decoded = jsonDecode(geminiOutput);

    final List<dynamic> gameList = decoded['games'];
    final List<dynamic> showList = decoded['shows'];
    final List<dynamic> movieList = decoded['movies'];

    // Clear previous recommendations and reasons
    recommendedGames.clear();
    gameReasons.clear();
    recommendedShows.clear();
    showReasons.clear();
    recommendedMovies.clear();
    movieReasons.clear();

    // Fetch details for recommended items concurrently
    await Future.wait([
      for (var game in gameList)
        searchGamesByName(game['title']).then((results) {
          if (results.isNotEmpty) {
            recommendedGames.add(results[0]);
            gameReasons.add(game['reason']);
          }
        }),
      for (var show in showList)
        searchShowsByName(show['title']).then((results) {
          if (results.isNotEmpty) {
            recommendedShows.add(results[0]);
            showReasons.add(show['reason']);
          }
        }),
      for (var movie in movieList)
        searchMoviesByName(movie['title']).then((results) {
          if (results.isNotEmpty) {
            recommendedMovies.add(results[0]);
            movieReasons.add(movie['reason']);
          }
        }),
    ]);

    setState(() => _pageState = PageState.results);
  }

  void _resetPage() {
    setState(() {
      _pageState = PageState.input;
      selectedOption = null;
      customController.clear();
    });
  }

  // ===== UI Widgets ===== //

  Widget buildTitle() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _sparkleController,
              builder:
                  (context, child) => Transform.rotate(
                    angle: _sparkleController.value * 2 * pi,
                    child: const Icon(
                      Icons.stars,
                      color: kPrimaryBlue,
                      size: 24,
                    ),
                  ),
            ),
            const SizedBox(width: 12),
            const Text(
              'AI Discovery',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(width: 12),
            AnimatedBuilder(
              animation: _sparkleController,
              builder:
                  (context, child) => Transform.rotate(
                    angle: _sparkleController.value * 2 * pi * -1,
                    child: const Icon(
                      Icons.stars,
                      color: kPrimaryBlue,
                      size: 24,
                    ),
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Your personal digital curator',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.7),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  BoxDecoration _glassmorphismDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          kPrimaryBlue.withOpacity(0.1),
          kPrimaryPurple.withOpacity(0.1),
        ],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: kPrimaryPurple.withOpacity(0.3), width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 30,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: kPrimaryBlue.withOpacity(0.1),
          blurRadius: 20,
          spreadRadius: -5,
        ),
      ],
    );
  }

  Widget _buildChoiceChip(String option, {bool isCustom = false}) {
    final bool isSelected = selectedOption == option;
    final text = isCustom ? 'Custom...' : option;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isSelected ? kPrimaryBlue.withOpacity(0.4) : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isSelected ? kPrimaryPurple : Colors.white.withOpacity(0.3),
        ),
        boxShadow:
            isSelected
                ? [
                  BoxShadow(
                    color: kPrimaryBlue.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
                : [],
      ),
      child: InkWell(
        onTap: () => setState(() => selectedOption = option),
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInputUI() {
    return Padding(
      key: const ValueKey('input'),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          buildTitle(),
          const SizedBox(height: 40),
          buildExperienceSelector(),
          const SizedBox(height: 32),
          buildDiscoverButton(),
        ],
      ),
    );
  }

  Widget buildExperienceSelector() {
    return Container(
      margin: const EdgeInsets.all(1.5),
      padding: const EdgeInsets.all(24),
      decoration: _glassmorphismDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '// WHAT ARE YOU IN THE MOOD FOR?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: kPrimaryBlue,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ...predefinedOptions.map((opt) => _buildChoiceChip(opt)),
              _buildChoiceChip('custom', isCustom: true),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child:
                (selectedOption == 'custom')
                    ? Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: TextField(
                        controller: customController,
                        decoration: InputDecoration(
                          hintText: 'Describe your ideal experience...',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                          ),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: kPrimaryBlue),
                          ),
                        ),
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white),
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget buildDiscoverButton() {
    return GestureDetector(
      onTap: selectedOption != null ? _generateRecommendations : null,
      child: AnimatedBuilder(
        animation: _buttonPulseController,
        builder: (context, child) {
          final isEnabled = selectedOption != null;
          return Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    isEnabled
                        ? [kPrimaryBlue, kPrimaryPurple]
                        : [Colors.grey.shade800, Colors.grey.shade900],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow:
                  isEnabled
                      ? [
                        BoxShadow(
                          color: kPrimaryBlue.withOpacity(0.6),
                          blurRadius: 10 + _buttonPulseController.value,
                          spreadRadius: 1,
                        ),
                      ]
                      : [],
            ),
            child: child,
          );
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, color: Colors.white),
            SizedBox(width: 12),
            Text(
              'Discover Your Next Obsession',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLoadingUI() {
    return const Center(
      key: ValueKey('loading'),
      child: FuturisticLoadingIndicator(),
    );
  }

  Widget buildResultsUI() {
    // The list of all items remains the same
    final allItems = [
      if (recommendedGames.isNotEmpty) '// RECOMMENDED_GAMES',
      ...recommendedGames,
      if (recommendedShows.isNotEmpty) '// RECOMMENDED_SHOWS',
      ...recommendedShows,
      if (recommendedMovies.isNotEmpty) '// RECOMMENDED_MOVIES',
      ...recommendedMovies,
    ];

    // NO MORE `allReasons` or `itemOffset` needed!

    return AnimationLimiter(
      key: const ValueKey('results'),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
        itemCount: allItems.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return _buildResetButton();

          final itemIndex = index - 1;
          final item = allItems[itemIndex];

          return AnimationConfiguration.staggeredList(
            position: itemIndex,
            duration: const Duration(milliseconds: 500),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child:
                    item is String
                        // It's a header
                        ? _buildSectionHeader(item)
                        // It's a recommendation item. We no longer pass a reason index.
                        : _buildRecommendationItem(item),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          color: kPrimaryBlue,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(dynamic item) {
    String reason = '';
    int index = -1;

    // Determine the item's type and find its reason
    if (item is Game) {
      index = recommendedGames.indexOf(item);
      if (index != -1) {
        reason = gameReasons[index];
      }
    } else if (item is Show) {
      index = recommendedShows.indexOf(item);
      if (index != -1) {
        reason = showReasons[index];
      }
    } else if (item is Movie) {
      index = recommendedMovies.indexOf(item);
      if (index != -1) {
        reason = movieReasons[index];
      }
    }

    // Only build the card if we found a valid reason
    if (reason.isNotEmpty) {
      return RecommendationCard(inEntry: item, inReason: reason);
    }

    // Fallback for safety, though it shouldn't be reached
    return const SizedBox.shrink();
  }

  Widget _buildResetButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: ElevatedButton.icon(
        onPressed: _resetPage,
        icon: const Icon(Icons.replay, size: 18),
        label: const Text('Start Over'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: kPrimaryPurple.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: kPrimaryPurple.withOpacity(0.5)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F0C29),
                  Color(0xFF302B63),
                  Color(0xFF24243E),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: ParticlesPainter(
                particles: particles,
                animation: _particlesController,
              ),
            ),
          ),
          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              transitionBuilder:
                  (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
              child: switch (_pageState) {
                PageState.input => buildInputUI(),
                PageState.loading => buildLoadingUI(),
                PageState.results => buildResultsUI(),
              },
            ),
          ),
        ],
      ),
    );
  }
}
