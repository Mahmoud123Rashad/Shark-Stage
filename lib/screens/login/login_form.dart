import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../services/auth_storage.dart';
import '../../theme/app_colors.dart';
import '../signup/signup_screen.dart';
import '../entrepreneur_bottom_nav_bar.dart';
import '../investor_bottom_nav_bar.dart';
import 'login_service.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  static const String _googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue:
        '931356072102-3e3t8tsus96899hdvci9spoj3ha8kqf8.apps.googleusercontent.com',
  );

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

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

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final result = await LoginService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      await _navigateAfterLogin(result);
    } else {
      _showSnack(result['message'] ?? "Login failed");
    }
  }

  Future<void> _navigateAfterLogin(Map<String, dynamic> result) async {
    final summary = await AuthStorage.getUserSummary();
    final role =
        (summary['role'] ?? result['role']?.toString())?.toLowerCase() ?? '';
    final email = summary['email'] ?? _emailController.text.trim();
    final userId = summary['id'];

    if (role == 'owner' || role == 'entrepreneur') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EntrepreneurBottomNavBar(
            email: email,
            userId: userId,
            role: role,
          ),
        ),
      );
    } else if (role == 'investor') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => InvestorBottomNavBar(
            email: email,
            userId: userId,
            role: role,
          ),
        ),
      );
    } else {
      _showSnack("Unknown user role");
    }
  }

  Future<void> _loginWithGoogle() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isLoading = true);

    try {
      final googleSignIn = GoogleSignIn(
        scopes: const ['email'],
        serverClientId: _googleServerClientId,
      );

      await googleSignIn.signOut();
      final account = await googleSignIn.signIn();
      if (account == null) {
        return;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;

      if (idToken == null || idToken.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to retrieve Google account token. Please try again.',
            ),
          ),
        );
        return;
      }

      final result = await LoginService.loginWithGoogle(idToken: idToken);
      if (result['success'] == true) {
        await _navigateAfterLogin(result);
      } else {
        _showSnack(result['message'] ?? 'Google login failed');
      }
    } catch (e) {
      _showSnack('Google sign-in error: $e');
    } finally {
      setState(() => _isLoading = false);
      try {
        final googleSignIn = GoogleSignIn(
          scopes: const ['email'],
          serverClientId: _googleServerClientId,
        );
        await googleSignIn.signOut();
      } catch (_) {}
    }
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

  Widget _buildGoogleSignInButton() {
    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.network(
          "https://upload.wikimedia.org/wikipedia/commons/0/09/IOS_Google_icon.png",
          width: 24,
          height: 24,
        ),
        const SizedBox(width: 12),
        const Flexible(
          child: Text(
            "Login with Google",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );

    final button = Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white24,
        ),
      ),
      child: Center(child: content),
    );

    return InkWell(
      onTap: _loginWithGoogle,
      borderRadius: BorderRadius.circular(12),
      child: button,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
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
              : Column(
                  children: [
                    SizedBox(
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
                    const SizedBox(height: 12),
                    _buildGoogleSignInButton(),
                  ],
                ),
          const SizedBox(height: 18),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SignUpScreen()),
              );
            },
            child: const Text(
              "Don't have an account? Sign Up",
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
