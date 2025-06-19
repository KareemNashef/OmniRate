// ==================== HELPER WIDGETS FOR PAGE CONTENT ==================== //

// Flutter imports
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';

// Local imports
import 'package:omnirate/Shared/utils.dart';
import 'package:omnirate/Shared/providers.dart';

// === 1. Reusable Styled Text Field ===
class StyledTextField extends StatelessWidget {
  const StyledTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.icon,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String labelText;
  final IconData icon;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.outline.withValues(alpha: 0.2),
            blurRadius: 4,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: colorScheme.surface.withValues(alpha: 0.1),
        ),
      ),
    );
  }
}

// === 2. Splash Screen Content ===
class SplashContent extends StatelessWidget {
  const SplashContent({super.key, required this.onGetStarted});
  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/settings/logo.png', height: 200),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
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
              child: Container(
                decoration: buttonDecoration(context),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: onGetStarted,
                  child: const Text(
                    "Get Started",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// === 3. Login Screen Content ===
class LoginContent extends StatefulWidget {
  const LoginContent({
    super.key,
    required this.onSignIn,
    required this.onSignUp,
  });
  final Future<void> Function(String email, String password) onSignIn;
  final VoidCallback onSignUp;

  @override
  State<LoginContent> createState() => LoginContentState();
}

class LoginContentState extends State<LoginContent> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSigningIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLocalSignIn() async {
    if (_isSigningIn) return;
    setState(() => _isSigningIn = true);
    await widget.onSignIn(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    if (mounted) {
      setState(() => _isSigningIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/settings/logo.png', height: 120),
            const SizedBox(height: 24),
            const Text(
              "Welcome!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Sign in to continue",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 40),
            StyledTextField(
              controller: _emailController,
              labelText: 'Email',
              icon: Icons.email,
            ),
            const SizedBox(height: 16),
            StyledTextField(
              controller: _passwordController,
              labelText: 'Password',
              icon: Icons.password,
              obscureText: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: buttonDecoration(context),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: _isSigningIn ? null : _handleLocalSignIn,
                  child:
                      _isSigningIn
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
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
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have an account? ",
                  style: TextStyle(color: Colors.white70),
                ),
                TextButton(
                  onPressed: widget.onSignUp,
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
}

// === 4. Onboarding Screen Content ===
class OnboardingContent extends StatefulWidget {
  const OnboardingContent({
    super.key,
    required this.onComplete,
    required this.onBackToLogin,
  });
  final Future<void> Function({
    required String email,
    required String password,
    required String username,
    required int avatarIndex,
    required Set<int> gameGenres,
    required Set<int> showGenres,
    required Set<int> movieGenres,
  })
  onComplete;
  final VoidCallback onBackToLogin;

  @override
  State<OnboardingContent> createState() => OnboardingContentState();
}

class OnboardingContentState extends State<OnboardingContent> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  int _selectedAvatarIndex = 0;
  final Set<int> _selectedGameGenres = {};
  final Set<int> _selectedShowGenres = {};
  final Set<int> _selectedMovieGenres = {};
  bool _isSigningUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _handleLocalOnboardingComplete() async {
    if (_isSigningUp) return;
    setState(() => _isSigningUp = true);

    await widget.onComplete(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      username: _usernameController.text.trim(),
      avatarIndex: _selectedAvatarIndex,
      gameGenres: _selectedGameGenres,
      showGenres: _selectedShowGenres,
      movieGenres: _selectedMovieGenres,
    );

    if (mounted) {
      setState(() => _isSigningUp = false);
    }
  }

  Widget _buildGenreCard(
    String title,
    List<Map<String, dynamic>> options,
    Set<int> selected,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _buildFiltersRow(options, selected),
        ],
      ),
    );
  }

  Widget _buildFiltersRow(
    List<Map<String, dynamic>> genres,
    Set<int> selectedSet,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            genres.map((genre) {
              final bool isSelected = selectedSet.contains(genre['id']);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: FilterChip(
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
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedSet.add(genre['id']);
                      } else {
                        selectedSet.remove(genre['id']);
                      }
                    });
                  },

                  backgroundColor: Color.fromRGBO(255, 255, 255, 0.1),
                  selectedColor: Theme.of(context).colorScheme.primary,
                  checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                  side: BorderSide(
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Color.fromRGBO(255, 255, 255, 0.3),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Logo
          const SizedBox(height: 40),
          Center(child: Image.asset('assets/settings/logo.png', height: 80)),

          // Padding
          const SizedBox(height: 40),

          // Text fields section
          sectionHeader(
            context,
            "Welcome aboard!",
            "We just need a little info to get started.",
          ),
          StyledTextField(
            controller: _emailController,
            labelText: 'Email',
            icon: Icons.email,
          ),
          const SizedBox(height: 16),
          StyledTextField(
            controller: _passwordController,
            labelText: 'Password',
            icon: Icons.password,
            obscureText: true,
          ),
          const SizedBox(height: 16),
          StyledTextField(
            controller: _usernameController,
            labelText: 'Choose a username',
            icon: Icons.account_box,
          ),
          const SizedBox(height: 32),

          // Avatar picker section
          sectionHeader(context, "Avatar time", "Show us your style!"),

          // Avatar picker
          Container(
            decoration: containerDecoration(context),
            padding: const EdgeInsets.all(10),

            child: GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 16,
              itemBuilder: (context, index) {
                final isSelected = _selectedAvatarIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAvatarIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform:
                        Matrix4.identity()..scale(isSelected ? 1.1 : 1.0),
                    transformAlignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // A simple border is MUCH faster than a shadow.
                      border: Border.all(
                        color:
                            isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                        width: isSelected ? 4 : 0,
                      ),
                    ),
                    child: ClipOval(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            'assets/ProfilePics/pic_${index + 1}.png',
                            fit: BoxFit.cover,
                          ),
                          // A simple colored overlay is also much faster.
                          if (isSelected)
                            Container(
                              color: Colors.black.withValues(alpha: 0.3),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Padding
          const SizedBox(height: 24),

          // Preferences Section
          sectionHeader(
            context,
            "Your Picks",
            "Select what you like the most!",
          ),
          const SizedBox(height: 12),

          _buildGenreCard("🎮 Game genres", genresGames, _selectedGameGenres),
          const SizedBox(height: 16),

          _buildGenreCard("📺 Show genres", genresShows, _selectedShowGenres),
          const SizedBox(height: 16),

          _buildGenreCard(
            "🎬 Movie genres",
            genresMovies,
            _selectedMovieGenres,
          ),
          const SizedBox(height: 24),

          const SizedBox(height: 40),

          // Continue button
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: buttonDecoration(context),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: _isSigningUp ? null : _handleLocalOnboardingComplete,
                child:
                    _isSigningUp
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
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
          ),
          const SizedBox(height: 16),

          // Back to login
          Center(
            child: TextButton(
              onPressed: widget.onBackToLogin,
              child: const Text(
                'Already have an account? Sign in',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// === 5. Theme Selection Content ===
class ThemeSelectionContent extends StatelessWidget {
  const ThemeSelectionContent({super.key, required this.onComplete});
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = [
      Color(0xFFEF5350),
      Color(0xFF66BB6A),
      Color(0xFF42A5F5),
      Color(0xFFFFEB3B),
      Color(0xFFAB47BC),
      Color(0xFFFF7043),
      Color(0xFF26C6DA),
    ];

    Widget colorButton(Color color) {
      final bool isSelected = context.watch<ThemeProvider>().mainColor == color;
      return GestureDetector(
        onTap: () => context.read<ThemeProvider>().setMainColor(color),
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

    Widget themeCard({
      required String assetPath,
      required String label,
      required ThemeMode themeMode,
    }) {
      final bool isSelected =
          context.watch<ThemeProvider>().themeMode == themeMode;

      return GestureDetector(
        onTap: () => context.read<ThemeProvider>().setThemeMode(themeMode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 280,
          height: 60,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isSelected
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Colors.transparent,
              width: 3,
            ),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer.withAlpha(64),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                    : null,
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Container(
                width: 40,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(assetPath, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const Spacer(),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(gradient: gradientBackground(context)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 60),

            // Header
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.palette,
                    size: 80,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Customize Your Experience',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose your theme and accent color',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Theme Mode Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Theme Mode',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Theme selection
            Column(
              children: [
                themeCard(
                  assetPath: 'assets/settings/LightMode.png',
                  label: 'Light Mode',
                  themeMode: ThemeMode.light,
                ),
                themeCard(
                  assetPath: 'assets/settings/DarkMode.png',
                  label: 'Dark Mode',
                  themeMode: ThemeMode.dark,
                ),
                themeCard(
                  assetPath: 'assets/settings/AutoMode.png',
                  label: 'Auto Mode',
                  themeMode: ThemeMode.system,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Accent Color Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Accent Color',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Color selection
            Column(
              children: colors.map((color) => colorButton(color)).toList(),
            ),

            const SizedBox(height: 40),

            // Done button
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: buttonDecoration(context),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    onComplete();
                  },
                  child: const Text(
                    'Apply Changes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Reset button
            Center(
              child: TextButton(
                onPressed: () {
                  context.read<ThemeProvider>().setThemeMode(ThemeMode.system);
                  context.read<ThemeProvider>().setMainColor(Color(0xFF42A5F5));
                },
                child: Text(
                  'Reset to Default',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
