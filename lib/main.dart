// ==================== Main App ==================== //

// Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Local imports
import 'package:omnirate/Main/main_page.dart';
import 'package:omnirate/Shared/providers.dart';
import 'package:omnirate/Main/welcome_page.dart';
import 'package:omnirate/Shared/user_data.dart';
import 'package:omnirate/Database/database_helper.dart';


final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  // Firebase initialization
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Hive initialization
  await Hive.initFlutter();
  Hive.registerAdapter(UserDataAdapter());
  Hive.registerAdapter(UserMediaEntryAdapter());
  await Hive.openBox<UserData>('userBox');
  await HiveHelper.init();

  // Dotenv initialization
  await dotenv.load();

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

  // Helper method to create system UI overlay style based on theme
  SystemUiOverlayStyle _getSystemUIStyle(ColorScheme colorScheme, Brightness brightness) {
    return SystemUiOverlayStyle(
      // Navigation bar styling
      systemNavigationBarColor: colorScheme.tertiaryContainer,
      systemNavigationBarIconBrightness: brightness == Brightness.dark 
          ? Brightness.light 
          : Brightness.dark,
      
      // Status bar styling
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: brightness == Brightness.dark 
          ? Brightness.light 
          : Brightness.dark,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get theme provider
    final themeProvider = context.watch<ThemeProvider>();

    return FutureBuilder<bool>(
      future: _seenWelcomeFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final seen = snapshot.data!;
        
        // Create light color scheme
        final lightColorScheme = ColorScheme.fromSeed(
          seedColor: themeProvider.mainColor,
          brightness: Brightness.light,
        );
        
        // Create dark color scheme
        final darkColorScheme = ColorScheme.fromSeed(
          seedColor: themeProvider.mainColor,
          brightness: Brightness.dark,
        );

        return MaterialApp(
          navigatorObservers: [routeObserver],

          // Define light theme with global system UI styling
          theme: ThemeData.from(
            colorScheme: lightColorScheme,
          ).copyWith(
            appBarTheme: AppBarTheme(
              systemOverlayStyle: _getSystemUIStyle(lightColorScheme, Brightness.light),
            ),
          ),

          // Define dark theme with global system UI styling
          darkTheme: ThemeData.from(
            colorScheme: darkColorScheme,
          ).copyWith(
            appBarTheme: AppBarTheme(
              systemOverlayStyle: _getSystemUIStyle(darkColorScheme, Brightness.dark),
            ),
          ),

          // Set theme mode
          themeMode: themeProvider.themeMode,

          // Global builder to handle safe area and system UI for ALL pages
          builder: (context, child) {
            // Get current theme colors
            final currentColorScheme = Theme.of(context).colorScheme;
            final currentBrightness = Theme.of(context).brightness;
            
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: _getSystemUIStyle(currentColorScheme, currentBrightness),
              child: SafeArea(
                // Allow content to extend behind status bar, but protect from navigation bar
                top: false,  // Don't add padding for status bar
                bottom: true,  // Add padding for navigation bar
                left: true,   // Protect from notches/cutouts on sides
                right: true,  // Protect from notches/cutouts on sides
                child: child!,
              ),
            );
          },

          // Set initial route
          home: seen ? MainPage() : WelcomePage(),
        );
      },
    );
  }
}