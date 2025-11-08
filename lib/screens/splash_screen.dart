import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/application/auth_controller.dart';
import '../features/auth/application/auth_state.dart';
import '../theme/app_colors.dart';
import 'entrepreneur_bottom_nav_bar.dart';
import 'intro_investor.dart';
import 'investor_bottom_nav_bar.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _navigated = false;
  late final ProviderSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _authSubscription = ref.listenManual<AuthState>(
      authControllerProvider,
      (_, AuthState next) => _handleAuthState(next),
    );

    // Handle the immediately available state if the user was cached.
    Future<void>.microtask(() {
      _handleAuthState(ref.read(authControllerProvider));
    });
  }

  @override
  void dispose() {
    _authSubscription.close();
    _controller.dispose();
    super.dispose();
  }

  void _handleAuthState(AuthState state) {
    state.maybeWhen(
      authenticated: (user) {
        final String role = user.accountType.toLowerCase();
        _navigateAfterDelay(() {
          final Widget destination = switch (role) {
            'entrepreneur' => const EntrepreneurBottomNavBar(),
            'owner' => const EntrepreneurBottomNavBar(),
            'admin' => const EntrepreneurBottomNavBar(),
            _ => const InvestorBottomNavBar(),
          };
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<Widget>(builder: (_) => destination),
          );
        });
      },
      unauthenticated: () {
        _navigateAfterDelay(() {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<Widget>(
              builder: (_) => const IntroInvestorScreen(),
            ),
          );
        });
      },
      failure: (message) {
        _navigateAfterDelay(() {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<Widget>(
              builder: (_) => const IntroInvestorScreen(),
            ),
          );
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: AppColors.danger,
              ),
            );
          });
        });
      },
      orElse: () {},
    );
  }

  void _navigateAfterDelay(VoidCallback callback) {
    if (_navigated || !mounted) return;
    _navigated = true;
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      callback();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.mainGradient),
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
                    border: Border.all(
                      color: const Color(0xFF5E7EC2),
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
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
                'SharkStage',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 200,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
