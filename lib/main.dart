// Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Local imports
import 'package:omnirate/Main/main_page.dart';
import 'package:omnirate/Shared/providers.dart';
import 'package:omnirate/Main/welcome_page.dart';

void main() async {
  // Firebase initialization
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Navigation bar color
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      // Providers
      providers: [ChangeNotifierProvider(create: (_) => ThemeProvider())],

      // Main app
      child: MainApp(),
    ),
  );
}

// ========== Main app ========== //

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  // Welcome page check
  late Future<bool> _seenWelcomeFuture;

  @override
  void initState() {
    super.initState();
    _seenWelcomeFuture = _checkSeenWelcome();
  }

  Future<bool> _checkSeenWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('seenWelcome') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // Get theme provider
    final themeProvider = context.watch<ThemeProvider>();

    return FutureBuilder<bool>(
      future: _seenWelcomeFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final seen = snapshot.data!;
        return MaterialApp(

          // Define light theme
          theme: ThemeData.from(
            colorScheme: ColorScheme.fromSeed(
              seedColor: themeProvider.mainColor,
              brightness: Brightness.light,
            ),
          ),

          // Define dark theme
          darkTheme: ThemeData.from(
            colorScheme: ColorScheme.fromSeed(
              seedColor: themeProvider.mainColor,
              brightness: Brightness.dark,
            ),
          ),

          // Set theme mode
          themeMode: themeProvider.themeMode,

          // Set initial route
          home: Scaffold(body: seen ? MainPage() : WelcomePage()),
        );
      },
    );
  }
}
