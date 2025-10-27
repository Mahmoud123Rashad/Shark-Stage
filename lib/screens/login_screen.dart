// lib/screens/login_screen.dart
import 'package:finial_project/screens/entrepreneur_bottom_nav_bar.dart';
import 'package:finial_project/screens/investor_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  final String baseUrl = "https://sharkserver-production.up.railway.app";

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('$baseUrl/auth/signin');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      debugPrint("🔹 Status Code: ${response.statusCode}");
      debugPrint("🔹 Response Body: ${response.body}");

      final data = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        if (data['token'] != null)
          await prefs.setString('token', data['token']);

        final role = data['user']?['accountType']?.toLowerCase();
        final email = _emailController.text.trim();

        if (role == 'owner' || role == 'entrepreneur') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => EntrepreneurBottomNavBar(email: email),
            ),
          );
        } else if (role == 'investor') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => InvestorBottomNavBar(email: email),
            ),
          );
        } else {
          _showSnack(" Unknown user role");
        }
      } else {
        _showSnack(data['message'] ?? " Login failed");
      }
    } catch (e) {
      _showSnack(" Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.button.withOpacity(0.95),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildTextField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: (v) => (v == null || v.isEmpty)
          ? (isPassword
                ? "Password must be at least 6 characters"
                : "Enter your email")
          : null,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.03),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.button),
        ),
      ),
    );
  }

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
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.soft, width: 2),
                        image: const DecorationImage(
                          image: AssetImage('images/Logo.jpeg'),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "Welcome Back",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 26),
                    _buildTextField(
                      icon: Icons.email_outlined,
                      label: "Email",
                      controller: _emailController,
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      icon: Icons.lock_outline,
                      label: "Password",
                      controller: _passwordController,
                      isPassword: true,
                    ),
                    const SizedBox(height: 22),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.button,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _login,
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(height: 18),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Don't have an account? Sign Up",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
