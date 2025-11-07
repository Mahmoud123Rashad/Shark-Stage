import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import '../login/login_screen.dart';
class SignUpServices {
  final String baseUrl = "https://sharkserver-production.up.railway.app";

  Future<void> _saveUserLocally({
    required String first,
    required String last,
    required String email,
    required String accountType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("firstName", first);
    await prefs.setString("lastName", last);
    await prefs.setString("email", email);
    await prefs.setString("accountType", accountType);
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.button.withOpacity(0.95),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> signUpWithEmail({
    required BuildContext context,
    required String first,
    required String last,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "firstName": first,
          "lastName": last,
          "email": email,
          "password": password,
          "accountType": role,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _saveUserLocally(
          first: first,
          last: last,
          email: email,
          accountType: role,
        );
        _showSnack(context, data["message"] ?? "Account created successfully");
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      } else {
        _showSnack(context, data['message'] ?? 'Error ${response.statusCode}');
      }
    } catch (e) {
      _showSnack(context, "Failed to connect: $e");
    }
  }

  Future<void> signInWithGoogle(BuildContext context, String role) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final email = googleUser.email;
      final name = googleUser.displayName ?? "";
      final response = await http.post(
        Uri.parse("$baseUrl/auth/google-signin"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "name": name, "accountType": role}),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final parts = name.split(' ');
        await _saveUserLocally(
          first: parts.first,
          last: parts.length > 1 ? parts.last : "",
          email: email,
          accountType: role,
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      } else {
        _showSnack(context, data['message'] ?? "Google login failed");
      }
    } catch (e) {
      _showSnack(context, "Error: $e");
    }
  }

  Future<void> signInWithLinkedIn(BuildContext context, String role) async {
    try {
      final email = "linkedinuser@example.com";
      final name = "LinkedIn User";
      final response = await http.post(
        Uri.parse("$baseUrl/auth/linkedin-signin"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "name": name, "accountType": role}),
      );
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        await _saveUserLocally(
          first: "LinkedIn",
          last: "User",
          email: email,
          accountType: role,
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      } else {
        _showSnack(context, data['message'] ?? "LinkedIn login failed");
      }
    } catch (e) {
      _showSnack(context, "Error: $e");
    }
  }
}
