import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
      colors: [Color(0xFF0D1117), Color(0xFF12151A)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Login"),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: const SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: LoginForm(),
            ),
          ),
        ),
      ),
    );
  }
}
