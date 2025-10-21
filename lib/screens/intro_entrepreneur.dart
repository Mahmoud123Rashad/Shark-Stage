import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';

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
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(seconds: 1),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                  child: Container(
                    key: ValueKey(_images[_currentIndex]),
                    width: 330,
                    height: 330,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: ClipOval(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            _images[_currentIndex],
                            fit: BoxFit.cover,
                            color: isDark
                                ? Colors.black.withOpacity(0.3)
                                : null, 
                            colorBlendMode:
                                isDark ? BlendMode.darken : BlendMode.srcOver,
                          ),

                          Center(
                            child: Stack(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white10
                                          : Colors.white24,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    width: 2,
                                    height: 260,
                                    color: isDark
                                        ? Colors.white12
                                        : Colors.white24,
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    width: 260,
                                    height: 2,
                                    color: isDark
                                        ? Colors.white12
                                        : Colors.white24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 35),
                Text(
                  "Project Owner",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: isDark ? Colors.white : Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        color: isDark
                            ? Colors.blueAccent.withOpacity(0.4)
                            : Colors.black38,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Text(
                  "Share your idea with real investors and turn your dream into a successful business in the world of entrepreneurship.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark ? Colors.white70 : Colors.white70,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 60),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDark ? Colors.blueAccent : AppColors.button,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      elevation: 8,
                      shadowColor:
                          isDark ? Colors.blueAccent.withOpacity(0.4) : Colors.black54,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
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
