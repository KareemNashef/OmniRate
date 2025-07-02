// ==================== HELPER WIDGETS FOR PAGE CONTENT ==================== //

// Flutter imports
import 'package:flutter/material.dart';
import 'package:omnirate/Settings/settings_theme.dart';
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
          // Logo
          Image.asset('assets/settings/logo.png', height: 200),

          // Padding
          const SizedBox(height: 20),

          // Subtitle
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

          // Padding
          const SizedBox(height: 60),

          // Continue Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: buttonDecoration(context),
              child: Material(
                color: Colors.transparent,

                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: onGetStarted,

                  child: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      "Get Started",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

class LoginContentState extends State<LoginContent>
    with TickerProviderStateMixin {
  // ===== Class Variables ===== //

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Form Key
  final _formKey = GlobalKey<FormState>();

  // State
  bool _isSigningIn = false;
  bool _isPasswordVisible = false;

  // Animations
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ===== Lifecycle Methods ===== //

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // ===== Class Methods ===== //

  Future<void> _handleLocalSignIn() async {
    if (_isSigningIn || !_formKey.currentState!.validate()) return;

    setState(() => _isSigningIn = true);

    try {
      await widget.onSignIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } finally {
      if (mounted) {
        setState(() => _isSigningIn = false);
      }
    }
  }

  // ===== Class Widgets ===== //

  Widget _buildLoginCard(BuildContext context, ColorScheme scheme) {
    return GlassContainer(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(scheme),
            const SizedBox(height: 40),
            _buildEmailField(),
            const SizedBox(height: 20),
            _buildPasswordField(),
            const SizedBox(height: 32),
            _buildSignInButton(),
            const SizedBox(height: 24),
            _buildSignUpPrompt(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme scheme) {
    return Column(
      children: [
        // App logo
        Container(
          // Padding
          padding: const EdgeInsets.all(16),

          // Theme
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.8),
                Theme.of(
                  context,
                ).colorScheme.tertiaryContainer.withValues(alpha: 0.8),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),

          // Logo
          child: Image.asset(
            'assets/settings/logo.png',
            height: 64,
            width: 64,
            errorBuilder:
                (context, error, stackTrace) => Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
          ),
        ),

        // Padding
        const SizedBox(height: 24),

        // Title
        Text(
          "Welcome Back",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: const Offset(0, 2),
                blurRadius: 4,
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),

        // Padding
        const SizedBox(height: 8),

        // Subtitle
        Text(
          "Sign in to continue your journey",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.8),
            shadows: [
              Shadow(
                offset: const Offset(0, 1),
                blurRadius: 2,
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return _buildGlassTextField(
      controller: _emailController,
      labelText: 'Email Address',
      icon: Icons.email_outlined,
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Email is required';
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
          return 'Enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return _buildGlassTextField(
      controller: _passwordController,
      labelText: 'Password',
      icon: Icons.lock_outlined,
      obscureText: !_isPasswordVisible,
      suffixIcon: IconButton(
        icon: Icon(
          _isPasswordVisible
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: Colors.white.withValues(alpha: 0.7),
        ),
        onPressed:
            () => setState(() => _isPasswordVisible = !_isPasswordVisible),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Password is required';
        if (value!.length < 6) return 'Password must be at least 6 characters';
        return null;
      },
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      // Theme
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),

      // Content
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        validator: validator,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: labelText,
          prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.6)),
          suffixIcon: suffixIcon,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          hintStyle: const TextStyle(color: Colors.white),
          labelStyle: const TextStyle(color: Colors.white),
          filled: true,
          fillColor: Colors.transparent,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.7)),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          errorStyle: TextStyle(
            color: Colors.red.shade300,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: buttonDecoration(context),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isSigningIn ? null : _handleLocalSignIn,
          child: Container(
            alignment: Alignment.center,
            child:
                _isSigningIn
                    ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Text
        Text(
          "Don't have an account? ",
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),

        // Padding
        const SizedBox(width: 4),

        // Button
        TextButton(
          onPressed: widget.onSignUp,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.white.withValues(alpha: 0.15),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Sign Up",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildLoginCard(context, scheme),
              ),
            ),
          ),
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
  })
  onComplete;
  final VoidCallback onBackToLogin;

  @override
  State<OnboardingContent> createState() => OnboardingContentState();
}

class OnboardingContentState extends State<OnboardingContent>
    with TickerProviderStateMixin {
  // ===== Class Variables ===== //

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  // State
  int _selectedAvatarIndex = 0;
  bool _isSigningUp = false;
  bool _isPasswordVisible = false;

  // Animations
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ===== Lifecycle Methods ===== //

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // ===== Class Methods ===== //

  Future<void> _handleLocalOnboardingComplete() async {
    if (_isSigningUp) return;
    setState(() => _isSigningUp = true);

    await widget.onComplete(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      username: _usernameController.text.trim(),
      avatarIndex: _selectedAvatarIndex,
    );

    if (mounted) {
      setState(() => _isSigningUp = false);
    }
  }

  // ===== Class Widgets ===== //

  Widget _buildOnboardingCard(BuildContext context, ColorScheme scheme) {
    return GlassContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(scheme),
          const SizedBox(height: 40),
          _buildEmailField(),
          const SizedBox(height: 20),
          _buildPasswordField(),
          const SizedBox(height: 20),
          _buildUsernameField(),
          const SizedBox(height: 20),
          _buildAvatarSelector(),
          const SizedBox(height: 20),
          _buildContinueButton(),
          const SizedBox(height: 20),
          _buildBackToLoginPrompt(),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme scheme) {
    return Column(
      children: [
        // App logo
        Container(
          // Padding
          padding: const EdgeInsets.all(16),

          // Theme
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.8),
                Theme.of(
                  context,
                ).colorScheme.tertiaryContainer.withValues(alpha: 0.8),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),

          // Logo
          child: Image.asset(
            'assets/settings/logo.png',
            height: 64,
            width: 64,
            errorBuilder:
                (context, error, stackTrace) => Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
          ),
        ),

        // Padding
        const SizedBox(height: 24),

        // Title
        Text(
          "Welcome aboard!",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: const Offset(0, 2),
                blurRadius: 4,
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),

        // Padding
        const SizedBox(height: 8),

        // Subtitle
        Text(
          "We just need a little info to get started.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.8),
            shadows: [
              Shadow(
                offset: const Offset(0, 1),
                blurRadius: 2,
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return _buildGlassTextField(
      controller: _emailController,
      labelText: 'Email Address',
      icon: Icons.email_outlined,
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Email is required';
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
          return 'Enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return _buildGlassTextField(
      controller: _passwordController,
      labelText: 'Password',
      icon: Icons.lock_outlined,
      obscureText: !_isPasswordVisible,
      suffixIcon: IconButton(
        icon: Icon(
          _isPasswordVisible
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: Colors.white.withValues(alpha: 0.7),
        ),
        onPressed:
            () => setState(() => _isPasswordVisible = !_isPasswordVisible),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Password is required';
        if (value!.length < 6) return 'Password must be at least 6 characters';
        return null;
      },
    );
  }

  Widget _buildUsernameField() {
    return _buildGlassTextField(
      controller: _usernameController,
      labelText: 'Username',
      icon: Icons.person_outlined,
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Username is required';
        if (value!.length < 3) return 'Username must be at least 3 characters';
        return null;
      },
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      // Theme
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),

      // Content
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        validator: validator,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: labelText,
          prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.6)),
          suffixIcon: suffixIcon,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          hintStyle: const TextStyle(color: Colors.white),
          labelStyle: const TextStyle(color: Colors.white),
          filled: true,
          fillColor: Colors.transparent,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.7)),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          errorStyle: TextStyle(
            color: Colors.red.shade300,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSelector() {
    return Column(
      children: [
        // Title
        Text(
          "Select your avatar",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),

        // Padding
        const SizedBox(height: 12),

        // Avatars
        GridView.builder(
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
                duration: const Duration(milliseconds: 300),
                transform: Matrix4.identity()..scale(isSelected ? 1.1 : 1.0),
                transformAlignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: isSelected ? 3 : 0,
                  ),
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: Colors.white.withAlpha(128),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                          : [],
                ),
                child: ClipOval(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/ProfilePics/pic_${index + 1}.png',
                        fit: BoxFit.cover,
                      ),
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
      ],
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: buttonDecoration(context),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _isSigningUp ? null : _handleLocalOnboardingComplete,

            child: Container(
              alignment: Alignment.center,
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
      ),
    );
  }

  Widget _buildBackToLoginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Text
        Text(
          "Already have an account? ",
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),

        // Padding
        const SizedBox(width: 4),

        // Button
        TextButton(
          onPressed: widget.onBackToLogin,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.white.withValues(alpha: 0.15),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Sign In",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  // ===== Build Method ===== //

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildOnboardingCard(context, scheme),
              ),
            ),
          ),
        ),
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
    return Container(
      // Background
      decoration: BoxDecoration(gradient: gradientBackground(context)),

      // Foreground
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 100, bottom: 32),
        child: Column(
          children: [
            // Padding
            const SizedBox(height: 60),

            // Header
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Padding
            const SizedBox(height: 40),

            // Theme Mode Section
            sectionHeader(context, "Theme Mode", "Choose how the app looks"),
            const SizedBox(height: 12),
            ThemeSettingsPage().themeSelectionBar(context),

            // Padding
            const SizedBox(height: 32),

            // Accent Color Section
            sectionHeader(context, "Accent Color", "Pick a color you like"),
            const SizedBox(height: 12),
            ThemeSettingsPage().colorSelectionBar(context),

            // Padding
            const SizedBox(height: 40),

            // Done button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: buttonDecoration(context),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      onComplete();
                    },

                    child: Container(
                      alignment: Alignment.center,
                      child: const Text(
                        'Apply Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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
