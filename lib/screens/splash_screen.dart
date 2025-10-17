import 'package:flutter/material.dart';
import 'dart:async';
import '../theme/app_colors.dart';
import 'intro_investor.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required void Function() onToggleTheme});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);

    Timer(const Duration(seconds: 10), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const IntroInvestorScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.mainGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             ScaleTransition(
  scale: Tween(begin: 0.9, end: 1.1).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  ),
  child: Container(
    width: 250, 
    height: 250, 
    decoration: BoxDecoration(
      shape: BoxShape.circle, 
      border: Border.all(color: const Color.fromARGB(255, 94, 126, 194), width: 4), 
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
      image: const DecorationImage(
        image: AssetImage('images/Logo.jpeg'),
        fit: BoxFit.cover,
      ),
    ),
  ),
),

              const SizedBox(height: 50),
              const Text(
                "SharkStage",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 200,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.button,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
