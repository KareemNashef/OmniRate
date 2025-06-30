// ==================== AI Discovery Page ==================== //

// Flutter imports
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:http/http.dart' as http;
import 'package:omnirate/API/igdb_api.dart';
import 'package:omnirate/API/tmdb_api.dart';

// Local imports
import 'package:omnirate/Home/helpers.dart';
import 'package:omnirate/Home/recommendation_card.dart';
import 'package:omnirate/Shared/list_use.dart';
import 'package:omnirate/Database/model_game.dart';
import 'package:omnirate/Database/model_movie.dart';
import 'package:omnirate/Database/model_show.dart';

// Color constants for the hardcoded theme

const Color kPrimaryBlue = Color(0xFF667EEA);
const Color kPrimaryPurple = Color(0xFF764BA2);

// Enum for page states

enum PageState { input, loading, results }

// ========== AI Discovery Page Class ========== //

class AIDiscoveryPage extends StatefulWidget {
  const AIDiscoveryPage({super.key});

  @override
  State<AIDiscoveryPage> createState() => _AIDiscoveryPageState();
}

class _AIDiscoveryPageState extends State<AIDiscoveryPage>
    with TickerProviderStateMixin {
  // ===== Class variables ===== //

  // State Variables
  PageState _pageState = PageState.input;
  int _suggestionCount = 2;
  List<String> _selectedMediaTypes = ['Games', 'Shows', 'Movies'];
  final List<String> _mediaTypes = ['Games', 'Shows', 'Movies'];
  // Controllers
  final TextEditingController customController = TextEditingController();
  late final AnimationController _sparkleController;
  late final AnimationController _buttonPulseController;
  late final AnimationController _particlesController;
  List<Particle> particles = [];

  // Recommendation Variables
  String? selectedOption;
  final List<String> predefinedOptions = [
    'Cozy evening',
    'Adventure seeker',
    'Romantic feeling',
    'Family fun time',
    'Mind-bending',
    'Nostalgic vibes',
  ];
  String geminiOutput = '';

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

  Future<String> getGeminiResponse(String prompt) async {
    const model = 'gemini-2.5-flash';
    const url =
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent';

    try {
      final response = await http.post(
        Uri.parse('$url?key=${dotenv.env['GEMINI_API_KEY'] ?? ''}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        final text =
            decodedResponse['candidates'][0]['content']['parts'][0]['text'];
        return text;
      } else {
        throw Exception(
          'API request failed with status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to get Gemini response: ${e.toString()}');
    }
  }

  String _extractJsonFromResponse(String response) {
    // Remove common markdown formatting
    String cleaned = response.trim();

    // Remove ```json and ``` markers
    cleaned = cleaned.replaceAll(RegExp(r'```json\s*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'```\s*$'), '');

    // Remove leading "json" or "JSON" if present
    cleaned = cleaned.replaceAll(RegExp(r'^json\s*', caseSensitive: false), '');

    // Find JSON boundaries
    int startIndex = cleaned.indexOf('{');
    int endIndex = cleaned.lastIndexOf('}');

    if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
      return cleaned.substring(startIndex, endIndex + 1);
    }

    return cleaned;
  }

  Future<void> _generateRecommendations() async {
    // Start the loading animation
    setState(() => _pageState = PageState.loading);

    // Generate the prompt and get the response
    final prompt = await _buildRecommendationPrompt();
    String geminiOutput = await getGeminiResponse(prompt);

    // Clean the response
    String cleanedJson = _extractJsonFromResponse(geminiOutput);
    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(cleanedJson);
    } catch (e) {
      cleanedJson = cleanedJson.replaceAll(RegExp(r'[^\x20-\x7E]'), '');
      decoded = jsonDecode(cleanedJson);
    }

    // Process the recommendations
    await _processRecommendations(decoded);

    // Stop the loading animation
    setState(() => _pageState = PageState.results);
  }

  Future<String> _buildRecommendationPrompt() async {
    final mood =
        selectedOption == 'custom'
            ? (customController.text.trim().isEmpty
                ? 'A custom experience'
                : customController.text.trim())
            : (selectedOption ?? 'No option selected');

    final suggestionsPerSelectedType =
        ((3 * _suggestionCount) / _selectedMediaTypes.length).ceil();

    final unselectedTypes =
        _mediaTypes.where((t) => !_selectedMediaTypes.contains(t)).toList();

    final buffer = StringBuffer();
    buffer.writeln(
      '''You are a recommendation engine. Suggest personalized games, shows, and movies based on a user's mood and history.
User's mood: $mood
User's viewing/playing history is below, formatted as: [Title]_[Rating/10]_[Status]''',
    );

    final futures = [
      getMediaByType('Games'),
      getMediaByType('Shows'),
      getMediaByType('Movies'),
    ];
    final results = await Future.wait(futures);
    final [listGames, listShows, listMovies] = results;

    if (listGames.isNotEmpty) {
      buffer.writeln('\nGames:');
      for (final game in listGames) {
        buffer.writeln('${game.name}_${game.rating}_${game.status}');
      }
    }
    if (listShows.isNotEmpty) {
      buffer.writeln('\nShows:');
      for (final show in listShows) {
        buffer.writeln('${show.name}_${show.rating}_${show.status}');
      }
    }
    if (listMovies.isNotEmpty) {
      buffer.writeln('\nMovies:');
      for (final movie in listMovies) {
        buffer.writeln('${movie.name}_${movie.rating}_${movie.status}');
      }
    }

    buffer.writeln('''
\nIMPORTANT INSTRUCTIONS:
Your entire response MUST be only a valid JSON object, with no extra text or markdown.

JSON Schema:
{
  "games": [ { "title": "...", "reason": "..." } ],
  "shows": [ { "title": "...", "reason": "..." } ],
  "movies": [ { "title": "...", "reason": "..." } ]
}

Rules:
- You MUST only provide recommendations for the following categories: ${_selectedMediaTypes.join(', ')}.
- The JSON response MUST NOT contain keys for these unselected categories: ${unselectedTypes.join(', ')}.
- Recommend exactly $suggestionsPerSelectedType items for each selected category.
- Reasons must be short (max 20 words).
- Do not suggest content already in the user's lists.
- If lists are empty, suggest popular content matching the mood.''');

    return buffer.toString();
  }

  Future<void> _processRecommendations(Map<String, dynamic> decoded) async {
    recommendedGames.clear();
    gameReasons.clear();
    recommendedShows.clear();
    showReasons.clear();
    recommendedMovies.clear();
    movieReasons.clear();

    final gameList =
        (decoded['games'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final showList =
        (decoded['shows'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final movieList =
        (decoded['movies'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    final futures = <Future>[];
    for (var game in gameList) {
      futures.add(
        searchGamesByName(game['title'] ?? '').then((results) {
          if (results.isNotEmpty) {
            recommendedGames.add(results[0]);
            gameReasons.add(game['reason'] ?? 'Recommended for you');
          }
        }),
      );
    }
    for (var show in showList) {
      futures.add(
        searchShowsByName(show['title'] ?? '').then((results) {
          if (results.isNotEmpty) {
            recommendedShows.add(results[0]);
            showReasons.add(show['reason'] ?? 'Recommended for you');
          }
        }),
      );
    }
    for (var movie in movieList) {
      futures.add(
        searchMoviesByName(movie['title'] ?? '').then((results) {
          if (results.isNotEmpty) {
            recommendedMovies.add(results[0]);
            movieReasons.add(movie['reason'] ?? 'Recommended for you');
          }
        }),
      );
    }
    await Future.wait(futures);
  }

  void _resetPage() {
    setState(() {
      _pageState = PageState.input;
      selectedOption = null;
      customController.clear();
      _selectedMediaTypes = ['Games', 'Shows', 'Movies'];
    });
  }

  BoxDecoration _glassmorphismDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          kPrimaryBlue.withValues(alpha: 0.1),
          kPrimaryPurple.withValues(alpha: 0.15),
        ],
        stops: const [0.1, 0.9],
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: kPrimaryPurple.withValues(alpha: 0.4),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.5),
          blurRadius: 30,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: kPrimaryBlue.withValues(alpha: 0.1),
          blurRadius: 20,
          spreadRadius: -5,
          offset: const Offset(0, -5),
        ),
      ],
    );
  }

  // ===== Class Widgets ===== //

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
            // Padding
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
            // Padding
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
        // Padding
        const SizedBox(height: 8),
        Text(
          'Your personal digital curator',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.7),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceChip(String option, {bool isCustom = false}) {
    final bool isSelected = selectedOption == option;
    final text = isCustom ? 'Custom...' : option;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      transform:
          isSelected ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(),
      transformAlignment: Alignment.center,
      decoration: BoxDecoration(
        gradient:
            isSelected
                ? const LinearGradient(
                  colors: [kPrimaryBlue, kPrimaryPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                : LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.1),
                  ],
                ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color:
              isSelected
                  ? Colors.transparent
                  : Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow:
            isSelected
                ? [
                  BoxShadow(
                    color: kPrimaryBlue.withValues(alpha: 0.5),
                    blurRadius: 14,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ]
                : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => selectedOption = option),
          borderRadius: BorderRadius.circular(30), // Match decoration
          splashColor: kPrimaryBlue.withValues(alpha: 0.3),
          highlightColor: kPrimaryPurple.withValues(alpha: 0.2),
          child: Padding(
            // KEY CHANGE: Adjusted padding for a wider, sleeker feel
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isCustom) ...[
                  const Icon(Icons.edit, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    // Bolder text on selection for better feedback
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
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
          // Padding
          const SizedBox(height: 40),

          // Header
          buildTitle(),

          // Padding
          const SizedBox(height: 40),

          // Experience selector
          buildExperienceSelector(),

          // Padding
          const SizedBox(height: 32),

          // Discover button
          buildDiscoverButton(),

          // Padding
          const SizedBox(height: 32),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            '// WHAT IS YOUR CURRENT VIBE?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: kPrimaryBlue,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
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
                          hintText: 'e.g., "A mind-bending sci-fi mystery"',
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          filled: true,
                          fillColor: Colors.black.withValues(alpha: 0.3),
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
                        minLines: 1,
                        style: const TextStyle(color: Colors.white),
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 28.0),
            child: Divider(
              color: kPrimaryPurple.withValues(alpha: 0.3),
              thickness: 1,
            ),
          ),
          const Text(
            '// CHOOSE CONTENT TYPES',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: kPrimaryBlue,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children:
                _mediaTypes.map((type) => _buildMediaTypeChip(type)).toList(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 28.0),
            child: Divider(
              color: kPrimaryPurple.withValues(alpha: 0.3),
              thickness: 1,
            ),
          ),
          const Text(
            '// HOW MANY SUGGESTIONS PER CATEGORY?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: kPrimaryBlue,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),
          _buildSuggestionCountSlider(),
        ],
      ),
    );
  }

  Widget _buildMediaTypeChip(String type) {
    final bool isSelected = _selectedMediaTypes.contains(type);
    final Map<String, IconData> icons = {
      'Games': Icons.videogame_asset_outlined,
      'Shows': Icons.tv_outlined,
      'Movies': Icons.movie_outlined,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color:
            isSelected
                ? kPrimaryBlue.withValues(alpha: 0.4)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color:
              isSelected ? kPrimaryPurple : Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow:
            isSelected
                ? [
                  BoxShadow(
                    color: kPrimaryBlue.withValues(alpha: 0.5),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
                : [],
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedMediaTypes.remove(type);
            } else {
              _selectedMediaTypes.add(type);
            }
          });
        },
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icons[type], color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                type,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionCountSlider() {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: kPrimaryBlue,
            inactiveTrackColor: kPrimaryPurple.withValues(alpha: 0.3),
            trackHeight: 4.0,
            thumbColor: kPrimaryPurple,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
            overlayColor: kPrimaryBlue.withValues(alpha: 0.24),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 24.0),
            tickMarkShape: const RoundSliderTickMarkShape(),
            activeTickMarkColor: kPrimaryBlue,
            inactiveTickMarkColor: Colors.white.withValues(alpha: 0.5),
            valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
            valueIndicatorColor: kPrimaryBlue,
            valueIndicatorTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: Slider(
            value: _suggestionCount.toDouble(),
            min: 1,
            max: 3,
            divisions: 2,
            onChanged: (double value) {
              setState(() {
                _suggestionCount = value.toInt();
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Less',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              ),
              Text(
                'More',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildDiscoverButton() {
    final bool isEnabled =
        selectedOption != null && _selectedMediaTypes.isNotEmpty;

    return GestureDetector(
      onTap: isEnabled ? _generateRecommendations : null,
      child: AnimatedBuilder(
        animation: _buttonPulseController,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
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
                          color: kPrimaryBlue.withValues(alpha: 0.6),
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
    return const Center(key: ValueKey('loading'), child: LoadingIndicator());
  }

  Widget buildResultsUI() {
    final allItems = [
      if (recommendedGames.isNotEmpty) '// RECOMMENDED_GAMES',
      ...recommendedGames,
      if (recommendedShows.isNotEmpty) '// RECOMMENDED_SHOWS',
      ...recommendedShows,
      if (recommendedMovies.isNotEmpty) '// RECOMMENDED_MOVIES',
      ...recommendedMovies,
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: _buildResultsHeader(),
        ),
        Expanded(
          child: AnimationLimiter(
            key: const ValueKey('results'),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
              itemCount: allItems.length,
              itemBuilder: (context, index) {
                final item = allItems[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 600),
                  child: SlideAnimation(
                    verticalOffset: 75.0,
                    child: FadeInAnimation(
                      child:
                          item is String
                              ? _buildSectionHeader(item)
                              : _buildRecommendationItem(item),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            color: kPrimaryBlue,
            margin: const EdgeInsets.only(right: 12),
          ),
          Text(
            title,
            style: const TextStyle(
              color: kPrimaryBlue,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Expanded(
            child: Text(
              'Curated For You',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _resetPage,
            icon: const Icon(Icons.replay, size: 18),
            label: const Text('Start Over'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: kPrimaryPurple.withValues(alpha: 0.3),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(color: kPrimaryPurple.withValues(alpha: 0.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(dynamic item) {
    String reason = '';
    int index = -1;

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

    if (reason.isNotEmpty) {
      return RecommendationCard(inEntry: item, inReason: reason);
    }
    return const SizedBox.shrink();
  }

  // ===== Build Method ===== //

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
                PageState.input => SingleChildScrollView(child: buildInputUI()),
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
