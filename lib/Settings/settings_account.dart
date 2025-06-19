// ==================== Games Main Page ==================== //

// Flutter imports
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Local imports
import 'package:omnirate/Main/welcome_page.dart';
import 'package:omnirate/Shared/firebase_service.dart';
import 'package:omnirate/Shared/user_data.dart';
import 'package:omnirate/Shared/utils.dart';

// ========== Account Settings Page Class ========== //

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  // ===== Class Variables ===== //

  // Firebase
  final FirebaseService _firebaseService = FirebaseService();

  // Controllers
  final _usernameController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  // Avatar Index
  int _avatarIndex = 0;

  // Loading
  bool _isLoadingUsername = false;
  bool _isLoadingPassword = false;
  bool _isLoadingSignOut = false;

  // Obscure
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // Hive
  UserData? _userData;
  Box<UserData>? _userBox;

  // ===== Lifecycle Methods ===== //

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _userBox = Hive.box<UserData>('userBox');
    if (_userBox!.isNotEmpty) {
      setState(() {
        _userData = _userBox?.get('user');
        _usernameController.text = _userData?.userName ?? '';
        _avatarIndex = _userData?.avatarIndex ?? 0;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  // ===== Class Methods ===== //

  Future<void> _changeUsername() async {
    // Check if user data is loaded
    if (_userData == null) {
      _showSnackBar('User data not loaded', isError: true);
      return;
    }

    // Check if the input is valid
    if (_usernameController.text.trim().isEmpty) {
      _showSnackBar('Username cannot be empty', isError: true);
      return;
    }
    if (_usernameController.text.trim() == _userData!.userName) {
      _showSnackBar('Username is the same as current', isError: true);
      return;
    }

    // Show loading indicator
    setState(() {
      _isLoadingUsername = true;
    });

    // Attempt to change username
    try {
      await _firebaseService.changeUsername(_usernameController.text.trim());
      _showSnackBar('Username updated successfully');

      // Update local user data in Hive
      _userData!.userName = _usernameController.text.trim();
      await _userBox!.putAt(0, _userData!);

      setState(() {});
    } catch (e) {
      _showSnackBar('Failed to update username: $e', isError: true);
    } finally {
      // Hide loading indicator
      setState(() {
        _isLoadingUsername = false;
      });
    }
  }

  Future<void> _changeAvatar() async {
    // Check if user data is loaded
    if (_userData == null) {
      _showSnackBar('User data not loaded', isError: true);
      return;
    }

    // Attempt to change avatar
    try {
      await _firebaseService.changeAvatar(_avatarIndex);
      _showSnackBar('Avatar updated successfully');

      // Update local user data in Hive
      _userData!.avatarIndex = _avatarIndex;
      await _userBox!.putAt(0, _userData!);

      setState(() {});
    } catch (e) {
      _showSnackBar('Failed to update avatar: $e', isError: true);
    }
  }

  Future<void> _changePassword() async {
    // Check if the input is valid
    if (_oldPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty) {
      _showSnackBar('Please fill in all password fields', isError: true);
      return;
    }
    
    if (_oldPasswordController.text.length < 6) {
      _showSnackBar('Password must be at least 6 characters', isError: true);
      return;
    }

    // Show loading indicator
    setState(() {
      _isLoadingPassword = true;
    });

    // Attempt to change password
    try {
      await _firebaseService.changePassword(
        _userData!.email,
        _oldPasswordController.text,
        _newPasswordController.text,
      );
      _showSnackBar('Password updated successfully');
      _oldPasswordController.clear();
      _newPasswordController.clear();
    } catch (e) {
      _showSnackBar('Failed to update password: $e', isError: true);
    } finally {
      // Hide loading indicator
      setState(() {
        _isLoadingPassword = false;
      });
    }
  }

  Future<void> _signOut() async {
    // Confirm sign out
    final shouldSignOut = await _showSignOutDialog();
    if (!shouldSignOut) return;

    // Show loading indicator
    setState(() {
      _isLoadingSignOut = true;
    });

    // Attempt to sign out
    try {
      // Sign out from firebase
      await _firebaseService.signOut();

      // Set app config to signed out
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seenWelcome', false);

      if (mounted) {
        // Navigate to welcome page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => WelcomePage()),
        );
      }
    } catch (e) {
      _showSnackBar('Failed to sign out: $e', isError: true);
    } finally {
      if (mounted) {
        // Hide loading indicator
        setState(() {
          _isLoadingSignOut = false;
        });
      }
    }
  }

  Future<bool> _showSignOutDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Sign Out'),
              content: const Text('Are you sure you want to sign out?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Sign Out'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ===== Class Widgets ===== //

  Widget accountInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: containerDecoration(context),

      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account's Email
              Text(
                'Email',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _userData?.email ?? 'Loading...',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget usernameSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: containerDecoration(context),

      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Username Input
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
              ),
            ),

            // Padding
            const SizedBox(height: 16),

            // Update Username Button
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
                  onPressed: _isLoadingUsername ? null : _changeUsername,
                  child:
                      _isLoadingUsername
                          ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.surface,
                            ),
                          )
                          : const Text('Update Username'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget avatarSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: containerDecoration(context),

      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
            final isSelected = _avatarIndex == index;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _avatarIndex = index;
                  _changeAvatar();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.identity()..scale(isSelected ? 1.1 : 1.0),
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
    );
  }

  Widget passwordSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: containerDecoration(context),

      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Password Inputs
            TextField(
              controller: _oldPasswordController,
              obscureText: _obscureNewPassword,
              decoration: InputDecoration(
                labelText: 'Old Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed:
                      () => setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      }),
                ),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
              ),
            ),

            // Padding
            const SizedBox(height: 16),

            // Confirm Password Input
            TextField(
              controller: _newPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'New Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed:
                      () => setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      }),
                ),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
              ),
            ),

            // Padding
            const SizedBox(height: 16),

            // Update Password Button
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
                  onPressed: _isLoadingPassword ? null : _changePassword,
                  child:
                      _isLoadingPassword
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Update Password'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget signOutSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: containerDecoration(context),

      child: Padding(
        padding: const EdgeInsets.all(16.0),

        // Sign Out Button
        child: SizedBox(
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red, Colors.orange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: _isLoadingSignOut ? null : _signOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  _isLoadingSignOut
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : const Text('Sign Out'),
            ),
          ),
        ),
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 100, bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account Info Section
              sectionHeader(context, "Account Info", "Your account details"),
              accountInfoSection(),

              // Change Username Section
              sectionHeader(context, "Change Username", "Update your username"),
              usernameSection(),

              // Change Avatar Section
              sectionHeader(context, "Change Avatar", "Update your avatar"),
              avatarSection(),

              // Change Password Section
              sectionHeader(context, "Change Password", "Update your password"),
              passwordSection(),

              // Sign Out Section
              sectionHeader(context, "Sign Out", "Sign out of your account"),
              signOutSection(),
            ],
          ),
        ),
      ),
    );
  }
}
