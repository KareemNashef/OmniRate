// ==================== Home Main Page ==================== //

// Flutter imports
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

// Local imports
import 'package:omnirate/BasePages/media_page.dart';
import 'package:omnirate/BasePages/list_page.dart';
import 'package:omnirate/Database/database_helper.dart';
import 'package:omnirate/Database/model_game.dart';
import 'package:omnirate/Database/model_movie.dart';
import 'package:omnirate/Database/model_show.dart';
import 'package:omnirate/Home/ai_discovery_page.dart';
import 'package:omnirate/Settings/settings_main.dart';
import 'package:omnirate/Shared/firebase_service.dart';
import 'package:omnirate/Shared/user_data.dart';
import 'package:omnirate/Shared/list_use.dart';
import 'package:omnirate/Shared/utils.dart';
import 'package:omnirate/main.dart';

// ========== Home Main Page Class ========== //

class HomeMainPage extends MediaPageBase {
  const HomeMainPage({super.key});

  @override
  HomeMainPageState createState() => HomeMainPageState();
}

class HomeMainPageState extends MediaPageBaseState
    with RouteAware, TickerProviderStateMixin {
  // ===== Class variables ===== //

  // Controllers
  late AnimationController _sparkleAnimationController;
  late AnimationController _arrowAnimationController;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _arrowAnimation;

  // Media lists
  late Future<List<UserMediaEntry>> futureGames;
  late Future<List<UserMediaEntry>> futureShows;
  late Future<List<UserMediaEntry>> futureMovies;

  // Ongoing media lists
  List<Game> ongoingGames = [];
  List<Show> ongoingShows = [];
  List<Movie> ongoingMovies = [];

  // Media loaded
  bool mediaLoaded = false;

  // ===== Lifecycle Methods ===== //

  @override
  void initState() {
    super.initState();

    // Sparkle rotation animation
    _sparkleAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _sparkleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _sparkleAnimationController,
        curve: Curves.linear,
      ),
    );

    // Arrow bounce animation
    _arrowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _arrowAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _arrowAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    initOngoingMedia();
  }

  void initOngoingMedia() async {
    // Load user data from firebase
    final firebaseService = FirebaseService();

    final data = await firebaseService.loadUserData();
    if (data != null) {
      final box = await Hive.openBox<UserData>('userBox');
      await box.put('user', data);
    }

    futureGames = getMediaByStatus("Games", "Current");
    futureShows = getMediaByStatus("Shows", "Current");
    futureMovies = getMediaByStatus("Movies", "Current");

    final games = await futureGames;
    final shows = await futureShows;
    final movies = await futureMovies;

    ongoingGames =
        (await Future.wait(
          games.map((e) => getGame(e.id)),
        )).whereType<Game>().toList();
    ongoingShows =
        (await Future.wait(
          shows.map((e) => getShow(e.id)),
        )).whereType<Show>().toList();
    ongoingMovies =
        (await Future.wait(
          movies.map((e) => getMovie(e.id)),
        )).whereType<Movie>().toList();

    mediaLoaded = true;
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void didPopNext() {
    // Called when you come back to this page
    refreshPage();
  }

  void refreshPage() {
    // Re-fetch data and update UI
    futureGames = getMediaByStatus("Games", "Current");
    futureShows = getMediaByStatus("Shows", "Current");
    futureMovies = getMediaByStatus("Movies", "Current");
    mediaLoaded = false;
    initOngoingMedia();
    setState(() {});
  }

  @override
  void dispose() {
    _sparkleAnimationController.dispose();
    _arrowAnimationController.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  Future<String> getTimeBasedGreeting() async {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    if (hour < 21) return "Good evening";
    return "Good night";
  }

  // ===== Class Widgets ===== //

  Widget buildWelcomeHeader() {
    return Container(
      // Padding
      margin: const EdgeInsets.symmetric(horizontal: 12),

      // Theme
      decoration: containerDecoration(context),

      // Content
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // Avatar
            FutureBuilder<int?>(
              future: getAvatarIndex(),
              builder: (context, snapshot) {
                final index = snapshot.data ?? 0;
                return CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: CircleAvatar(
                    radius: 28,
                    backgroundImage: AssetImage(
                      'assets/ProfilePics/pic_${index + 1}.png',
                    ),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                  ),
                );
              },
            ),

            // Padding
            const SizedBox(width: 16),

            // Greeting
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Time
                  FutureBuilder<String>(
                    future: getTimeBasedGreeting(),
                    builder: (context, snapshot) {
                      final greeting = snapshot.data ?? 'Welcome back';
                      return Text(
                        greeting,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      );
                    },
                  ),

                  // Name
                  FutureBuilder<String?>(
                    future: getUsername(),
                    builder: (context, snapshot) {
                      final name = snapshot.data ?? 'User';
                      return ShaderMask(
                        shaderCallback:
                            (bounds) => LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                            ).createShader(bounds),
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.8,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Settings
            Container(
              // Padding
              margin: const EdgeInsets.only(right: 8),

              // Theme
              decoration: buttonDecoration(context),

              // Content
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  );
                },
                icon: Icon(
                  Icons.settings_rounded,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 26,
                ),
                padding: const EdgeInsets.all(10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProgressCard(String type, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(
              MaterialPageRoute<void>(
                builder: (context) => ListPage(listType: type),
              ),
            )
            .then((_) => setState(() {}));
      },
      child: FutureBuilder<List<UserMediaEntry>?>(
        future: getMediaByType(type),
        builder: (context, snapshot) {
          final count = snapshot.data?.length ?? 0;
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.1),
                  color.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 12),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  type,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  'Tracked',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildProgressStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: GestureDetector(
              child: buildProgressCard(
                "Games",
                Icons.videogame_asset_rounded,
                Colors.blue,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: buildProgressCard("Shows", Icons.tv_rounded, Colors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: buildProgressCard(
              "Movies",
              Icons.movie_rounded,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDiscoverButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute<void>(
                  builder: (context) => AIDiscoveryPage(),
                ),
              )
              .then((_) => setState(() {}));
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF667EEA), Color(0xFF764BA2), Color(0xFF667EEA)],
              stops: [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667EEA).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(-2, -2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Animated background particles
              Positioned.fill(child: CustomPaint(painter: ParticlesPainter())),
              // Main content
              Row(
                children: [
                  // AI Icon with pulsing effect
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Pulsing glow effect
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        // Main AI icon
                        const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'AI Discovery',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Animated sparkle
                            AnimatedBuilder(
                              animation: _sparkleAnimation,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _sparkleAnimation.value * 2 * 3.14159,
                                  child: const Icon(
                                    Icons.stars,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Personalized recommendations',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Arrow with subtle animation
                  AnimatedBuilder(
                    animation: _arrowAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_arrowAnimation.value * 2, 0),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white.withValues(alpha: 0.8),
                          size: 16,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget emptyOngoing() {
    return Container(
      // Padding
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(32),

      // Theme
      decoration: containerDecoration(context),

      // Content
      child: Column(
        children: [
          // Empty State Icon
          Container(
            // Padding
            padding: const EdgeInsets.all(16),

            // Theme
            decoration: buttonDecoration(context),

            // Icon
            child: Icon(
              Icons.explore_outlined,
              size: 48,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.7),
            ),
          ),

          const SizedBox(height: 20),

          // Main Message
          Text(
            'Nothing Currently Active',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            'Your ongoing lists are empty.\nTime to start something new!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    if (!mediaLoaded) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: gradientBackground(context)),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: buttonDecoration(context),
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Loading your media...",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "This won't take long!",
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(gradient: gradientBackground(context)),

      child: RefreshIndicator(
        onRefresh: () async {
          // Load user data from firebase
          final firebaseService = FirebaseService();

          final data = await firebaseService.loadUserData();
          if (data != null) {
            final box = await Hive.openBox<UserData>('userBox');
            await box.put('user', data);
          }

          refreshPage();
        },

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Padding
                SizedBox(height: 40),

                buildWelcomeHeader(),
                const SizedBox(height: 24),
                sectionHeader(
                  context,
                  "My Collections",
                  "A central hub to track everything you enjoy.",
                ),
                const SizedBox(height: 8),

                buildProgressStats(),
                const SizedBox(height: 12),

                buildDiscoverButton(),
                const SizedBox(height: 12),

                if (ongoingGames.isNotEmpty ||
                    ongoingShows.isNotEmpty ||
                    ongoingMovies.isNotEmpty) ...[
                  if (ongoingGames.isNotEmpty) ...[
                    blankCarousel(
                      "Games",
                      "Ongoing Games",
                      "Games you're actively enjoying",
                      ongoingGames,
                      inShowArrow: false,
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (ongoingShows.isNotEmpty) ...[
                    blankCarousel(
                      "Shows",
                      "Ongoing Shows",
                      "Shows you're following",
                      ongoingShows,
                      inShowArrow: false,
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (ongoingMovies.isNotEmpty) ...[
                    blankCarousel(
                      "Movies",
                      "Ongoing Movies",
                      "Films on your watchlist",
                      ongoingMovies,
                      inShowArrow: false,
                    ),
                    const SizedBox(height: 24),
                  ],
                ] else ...[
                  emptyOngoing(),
                  const SizedBox(height: 24),
                ],

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ParticlesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.1)
          ..style = PaintingStyle.fill;

    // Draw floating particles
    final particles = [
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.7, size.height * 0.2),
      Offset(size.width * 0.8, size.height * 0.7),
      Offset(size.width * 0.3, size.height * 0.8),
      Offset(size.width * 0.9, size.height * 0.4),
    ];

    for (final particle in particles) {
      canvas.drawCircle(particle, 2, paint);
    }

    // Draw connecting lines
    final linePaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.05)
          ..strokeWidth = 0.5
          ..style = PaintingStyle.stroke;

    canvas.drawLine(particles[0], particles[1], linePaint);
    canvas.drawLine(particles[1], particles[2], linePaint);
    canvas.drawLine(particles[3], particles[4], linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
