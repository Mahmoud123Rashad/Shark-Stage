import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:finial_project/screens/splash_screen.dart';
import 'theme/app_colors.dart';
import 'firebase_options.dart'; // flutterfire configure

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SharkTankApp());
}

class SharkTankApp extends StatefulWidget {
  const SharkTankApp({super.key});

  @override
  State<SharkTankApp> createState() => _SharkTankAppState();
}

class _SharkTankAppState extends State<SharkTankApp> {
  ThemeMode _themeMode = ThemeMode.system; //  Auto switch by default

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shark Tank',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode, //  Switch between light/dark
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.button,
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
          titleLarge: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.button,
          brightness: Brightness.dark,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      home: SplashScreen(
        onToggleTheme: _toggleTheme, 
      ),
    );
  }
}
