import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'intro_entrepreneur.dart';

class IntroInvestorScreen extends StatefulWidget {
  const IntroInvestorScreen({super.key});

  @override
  State<IntroInvestorScreen> createState() => _IntroInvestorScreenState();
}

class _IntroInvestorScreenState extends State<IntroInvestorScreen> {
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //  Sniper Image Slider 
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
                    decoration: BoxDecoration(
                      // shape: BoxShape.circle,
                      // border: Border.all(
                      //   // color: AppColors.button,
                      //   // width: 4,
                      // ),
                    //   boxShadow: [
                    //     BoxShadow(
                    //       color: Colors.black.withOpacity(0.3),
                    //       blurRadius: 15,
                    //       offset: const Offset(0, 8),
                    //     ),
                    //   ],
                    ),
                    child: ClipOval(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            _images[_currentIndex],
                            fit: BoxFit.cover,
                          ),
                          // Crosshair overlay
                          Center(
                            child: Stack(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    // border: Border.all(
                                    //     color: Colors.white24, width: 1),
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    width: 2,
                                    height: 260,
                                    color: Colors.white24,
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    width: 260,
                                    height: 2,
                                    color: Colors.white24,
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

                const Text(
                  "Investor",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 20),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    "Discover new ideas and invest in promising projects to be part of their future success.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      height: 1.6,
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // 🔘 Next Button
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.button,
                      foregroundColor: AppColors.heading,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      elevation: 6,
                      shadowColor: Colors.black54,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const IntroEntrepreneurScreen(),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Next",
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
