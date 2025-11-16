import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  // رابط السيرفر
  final String baseUrl = "https://sharkserver-production.up.railway.app";

  void _showSnack(String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color ?? AppColors.button.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

Future<void> _changePassword() async {
  final current = _currentPasswordController.text.trim();
  final newPass = _newPasswordController.text.trim();
  final confirm = _confirmPasswordController.text.trim();

  if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
    _showSnack("من فضلك املأ كل الحقول", color: Colors.red);
    return;
  }

  // Normalize: نزيل المسافات ونقارن بالـ exact match
  if (newPass != confirm) {
    _showSnack("كلمات المرور الجديدة غير متطابقة", color: Colors.red);
    return;
  }

  setState(() => _isLoading = true);

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      _showSnack("⚠️ لم يتم العثور على توكن. يرجى تسجيل الدخول مجددًا.", color: Colors.red);
      setState(() => _isLoading = false);
      return;
    }

    final uri = Uri.parse("$baseUrl/auth/change-password");
    final response = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "currentPassword": current,
        "newPassword": newPass,
      }),
    );

    if (response.statusCode == 200) {
      _showSnack("✅ تم تغيير كلمة المرور بنجاح", color: Colors.green);
      Navigator.pop(context);
    } else {
      try {
        final data = jsonDecode(response.body);
        _showSnack(data['message'] ?? "فشل في تغيير كلمة المرور", color: Colors.red);
      } catch (_) {
        _showSnack("❌ خطأ من الخادم: ${response.body}", color: Colors.red);
      }
    }
  } catch (e) {
    _showSnack("⚠️ حدث خطأ: $e", color: Colors.red);
  } finally {
    setState(() => _isLoading = false);
  }
}


  Widget _buildTextField(String label, TextEditingController controller, {bool obscure = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.button, width: 1.6),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
      colors: [Color(0xFF0D1117), Color(0xFF161B22)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Change Password"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildTextField("Current Password", _currentPasswordController, obscure: true),
                _buildTextField("New Password", _newPasswordController, obscure: true),
                _buildTextField("Confirm New Password", _confirmPasswordController, obscure: true),
                const SizedBox(height: 30),
                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.lock_reset, color: Colors.white),
                          label: const Text(
                            "Change Password",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.button,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _changePassword,
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
