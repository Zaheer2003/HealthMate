import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:health_mate/features/auth/views/login_page.dart';
import 'package:health_mate/features/health_records/viewmodels/health_record_controller.dart';
import 'package:health_mate/services/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HealthRecordController().init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => HealthRecordController()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'HealthMate App',
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            primarySwatch: Colors.teal,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            scaffoldBackgroundColor: const Color(0xFFF0F4F3), // A very light minty-white
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF86CBC1),
              primary: const Color(0xFF86CBC1), // minty green/cyan
              secondary: const Color(0xFF68A0A6), // darker minty blue
              background: const Color(0xFFF0F4F3),
              surface: Colors.white,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onBackground: Colors.black87,
              onSurface: Colors.black87,
              onError: Colors.white,
              error: Colors.redAccent,
            ),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF86CBC1),
              foregroundColor: Colors.white,
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFF68A0A6),
              foregroundColor: Colors.white,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF68A0A6),
                foregroundColor: Colors.white,
              ),
            ),
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.teal,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            scaffoldBackgroundColor: const Color(0xFF121212), // Dark background
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF86CBC1),
              brightness: Brightness.dark,
              primary: const Color(0xFF86CBC1), // minty green/cyan
              secondary: const Color(0xFF68A0A6), // darker minty blue
              background: const Color(0xFF121212),
              surface: const Color(0xFF1E1E1E),
              onPrimary: Colors.black,
              onSecondary: Colors.black,
              onBackground: Colors.white70,
              onSurface: Colors.white70,
              onError: Colors.black,
              error: Colors.redAccent,
            ),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFF68A0A6),
              foregroundColor: Colors.black,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF68A0A6),
                foregroundColor: Colors.black,
              ),
            ),
          ),
          debugShowCheckedModeBanner: false, // Remove debug banner
          home: const LoginPage(), // Set LoginPage as the initial home
        );
      },
    );
  }
}
