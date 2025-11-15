import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'login/login_screen.dart';

class IntroEntrepreneurScreen extends StatefulWidget {
  const IntroEntrepreneurScreen({super.key});

  @override
  State<IntroEntrepreneurScreen> createState() =>
      _IntroEntrepreneurScreenState();
}

class _IntroEntrepreneurScreenState extends State<IntroEntrepreneurScreen> {
  final List<String> _images = [
    'images/invest01.webp',
    'images/invest02.png',
    'images/invest03.jpg',
    'images/invest04.png',
  ];

  int _currentIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _images.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [Color(0xFF0A0E21), Color(0xFF1C1F2E)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : AppColors.mainGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Expanded(
                  // <<<<< FIX: prevents overflow
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ANIMATION FIXED
                      AnimatedSwitcher(
                        duration: const Duration(seconds: 1),
                        transitionBuilder: (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                        child: SizedBox(
                          key: ValueKey(_images[_currentIndex]),
                          width: 260,
                          height: 260,
                          child: ClipOval(
                            child: Image.asset(
                              _images[_currentIndex],
                              fit: BoxFit.cover,
                              color: isDark
                                  ? Colors.black.withOpacity(0.3)
                                  : null,
                              colorBlendMode: isDark
                                  ? BlendMode.darken
                                  : BlendMode.srcOver,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      Text(
                        "Project Owner",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          "Share your idea with real investors and turn your dream into a successful business in the world of entrepreneurship.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.white70,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // BUTTON AT BOTTOM
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? Colors.blueAccent
                          : AppColors.button,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      elevation: 8,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Get Started",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_ios, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
