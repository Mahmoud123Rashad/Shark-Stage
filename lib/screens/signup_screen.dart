// lib/screens/signup_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import '../theme/app_colors.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? selectedRole;
  bool _isLoading = false;

  final String baseUrl = "https://sharkserver-production.up.railway.app";

  Future<void> _saveUserLocally({
    required String firstName,
    required String lastName,
    required String email,
    required String accountType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("firstName", firstName);
    await prefs.setString("lastName", lastName);
    await prefs.setString("email", email);
    await prefs.setString("accountType", accountType);
  }

  Future<void> _signUpWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedRole == null) {
      _showSnack("Please select your account type");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse("$baseUrl/auth/signup");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "firstName": _firstNameController.text.trim(),
          "lastName": _lastNameController.text.trim(),
          "email": _emailController.text.trim(),
          "password": _passwordController.text.trim(),
          "accountType": selectedRole!.toLowerCase(),
        }),
      );

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        data = {"message": response.body};
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _saveUserLocally(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          accountType: selectedRole!.toLowerCase(),
        );

        _showSnack(data["message"] ?? "Account created successfully ");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        _showSnack(" ${data['message'] ?? 'Error ${response.statusCode}'}");
      }
    } catch (e) {
      _showSnack(" Failed to connect to server: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final email = googleUser.email;
      final name = googleUser.displayName ?? "";

      final response = await http.post(
        Uri.parse("$baseUrl/auth/google-signin"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "name": name,
          "accountType": selectedRole?.toLowerCase() ?? "owner",
        }),
      );

      final data = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        final nameParts = name.split(' ');
        await _saveUserLocally(
          firstName: nameParts.isNotEmpty ? nameParts.first : "",
          lastName: nameParts.length > 1 ? nameParts.last : "",
          email: email,
          accountType: selectedRole?.toLowerCase() ?? "owner",
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        _showSnack(data['message'] ?? "Google login failed");
      }
    } catch (e) {
      _showSnack("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithLinkedIn() async {
    setState(() => _isLoading = true);
    try {
      final email = "linkedinuser@example.com";
      final name = "LinkedIn User";

      final response = await http.post(
        Uri.parse("$baseUrl/auth/linkedin-signin"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "name": name,
          "accountType": selectedRole?.toLowerCase() ?? "owner",
        }),
      );

      final data = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        final nameParts = name.split(' ');
        await _saveUserLocally(
          firstName: nameParts.isNotEmpty ? nameParts.first : "",
          lastName: nameParts.length > 1 ? nameParts.last : "",
          email: email,
          accountType: selectedRole?.toLowerCase() ?? "owner",
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        _showSnack(data['message'] ?? "LinkedIn login failed");
      }
    } catch (e) {
      _showSnack("Error: $e");
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

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
      colors: [Color(0xFF0D1117), Color(0xFF12151A)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final panelColor = Colors.white.withOpacity(0.06);
    final inputFill = Colors.white.withOpacity(0.03);
    final labelStyle = const TextStyle(color: Colors.white70);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Sign Up'),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              children: [
                const SizedBox(height: 8),
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
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  "Create Your Account",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text("Sign up to access your dashboard", style: labelStyle),
                const SizedBox(height: 26),
                _buildForm(panelColor, inputFill, labelStyle),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(Color panelColor, Color inputFill, TextStyle labelStyle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildInputField(
              icon: Icons.person,
              label: "First Name",
              controller: _firstNameController,
              validatorMsg: "Please enter your first name",
              fillColor: inputFill,
              labelStyle: labelStyle,
            ),
            const SizedBox(height: 14),
            _buildInputField(
              icon: Icons.person_outline,
              label: "Last Name",
              controller: _lastNameController,
              validatorMsg: "Please enter your last name",
              fillColor: inputFill,
              labelStyle: labelStyle,
            ),
            const SizedBox(height: 14),
            _buildInputField(
              icon: Icons.email_rounded,
              label: "Email",
              controller: _emailController,
              validatorMsg: "Please enter your email",
              fillColor: inputFill,
              labelStyle: labelStyle,
            ),
            const SizedBox(height: 14),
            _buildInputField(
              icon: Icons.lock_rounded,
              label: "Password",
              controller: _passwordController,
              isPassword: true,
              validatorMsg: "Password must be at least 6 characters",
              fillColor: inputFill,
              labelStyle: labelStyle,
            ),
            const SizedBox(height: 18),
            Align(alignment: Alignment.centerLeft, child: Text("Account Type", style: labelStyle)),
            const SizedBox(height: 8),
            ToggleButtons(
              isSelected: [selectedRole == "owner", selectedRole == "investor"],
              borderRadius: BorderRadius.circular(12),
              fillColor: AppColors.button.withOpacity(0.18),
              selectedColor: AppColors.button,
              color: Colors.white70,
              onPressed: (index) {
                setState(() {
                  selectedRole = index == 0 ? "owner" : "investor";
                });
              },
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  child: Text("Owner"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  child: Text("Investor"),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _isLoading
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      _buildButton("Sign Up", _signUpWithEmail),
                      const SizedBox(height: 16),
                      _buildSocialButton(
                        "Sign up with Google",
                        "https://upload.wikimedia.org/wikipedia/commons/0/09/IOS_Google_icon.png",
                        _signInWithGoogle,
                      ),
                      const SizedBox(height: 12),
                      _buildSocialButton(
                        "Sign up with LinkedIn",
                        "https://upload.wikimedia.org/wikipedia/commons/c/ca/LinkedIn_logo_initials.png",
                        _signInWithLinkedIn,
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.button,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        child: Text(text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSocialButton(String text, String logoUrl, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(logoUrl, width: 24, height: 24),
            const SizedBox(width: 12),
            Text(text,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
    required String validatorMsg,
    required Color fillColor,
    required TextStyle labelStyle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: (v) => (v == null || v.isEmpty) ? validatorMsg : null,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70),
        labelText: label,
        labelStyle: labelStyle,
        filled: true,
        fillColor: fillColor,
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
}
