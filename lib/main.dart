// Flutter imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Local imports
import 'Main/main_page.dart';
import 'package:omnirate/Shared/providers.dart';

void main() {
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
  @override
  Widget build(BuildContext context) {

    // Get theme provider
    final themeProvider = context.watch<ThemeProvider>();

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
      home: Scaffold(body: MainPage()),
    );
  }
}
