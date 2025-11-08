import 'package:flutter/material.dart';
import 'dart:async';
import '../theme/app_colors.dart';
import '../services/auth_storage.dart';
import 'entrepreneur_bottom_nav_bar.dart';
import 'intro_investor.dart';
import 'investor_bottom_nav_bar.dart';
import 'profile/profile_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _startNavigationSequence();
  }

  Future<void> _startNavigationSequence() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    try {
      final token = await AuthStorage.getToken();
      if (!mounted) return;

      if (token == null || token.isEmpty) {
        _navigateTo(const IntroInvestorScreen());
        return;
      }

      var summary = await AuthStorage.getUserSummary();
      var role = summary['role']?.toLowerCase();
      var email = summary['email'];
      var userId = summary['id'];

      if ((role == null || role.isEmpty) || (email == null || email.isEmpty)) {
        final profile = await ProfileService.fetchProfile();
        if (profile != null) {
          role = profile['accountType']?.toString().toLowerCase() ?? role;
          email = profile['email']?.toString() ?? email;
          userId =
              profile['_id']?.toString() ?? profile['id']?.toString() ?? userId;
        }
      }

      if (!mounted) return;

      switch (role) {
        case 'owner':
        case 'entrepreneur':
          _navigateTo(
            EntrepreneurBottomNavBar(
              email: email ?? '',
              userId: userId,
              role: role,
            ),
          );
          break;
        case 'investor':
          _navigateTo(
            InvestorBottomNavBar(
              email: email ?? '',
              userId: userId,
              role: role,
            ),
          );
          break;
        default:
          await AuthStorage.clear();
          _navigateTo(const IntroInvestorScreen());
      }
    } catch (_) {
      if (!mounted) return;
      _navigateTo(const IntroInvestorScreen());
    }
  }

  void _navigateTo(Widget page) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: Tween(begin: 0.9, end: 1.1).animate(
                  CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
                ),
                child: Container(
                  width: 230,
                  height: 230,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? Colors.blueAccent.withOpacity(0.6)
                          : const Color.fromARGB(255, 94, 126, 194),
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.blueAccent.withOpacity(0.25)
                            : Colors.black.withOpacity(0.3),
                        blurRadius: 20,
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

              const SizedBox(height: 40),
              Text(
                "SharkStage",
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(
                      color: isDark
                          ? Colors.blueAccent.withOpacity(0.4)
                          : Colors.black26,
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 180,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.blueAccent : AppColors.button,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),

              const SizedBox(height: 20),
              Text(
                "Empowering Startups & Investors",
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.white70,
                  fontSize: 14,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
