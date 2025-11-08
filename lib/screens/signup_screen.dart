import 'package:finial_project/features/auth/application/auth_controller.dart';
import 'package:finial_project/features/auth/application/auth_state.dart';
import 'package:finial_project/features/auth/domain/app_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;

import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import 'add_project.dart';
import 'projects_screen.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key, required void Function() onToggleTheme});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? selectedRole;

  void _authListener(AuthState? previous, AuthState next) {
    next.when(
      initial: () {},
      loading: (_) {},
      authenticated: _navigateAfterSignup,
      unauthenticated: () {},
      failure: _showSnack,
    );
  }

  Future<void> _signUpWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedRole == null) {
      _showSnack('Please select your role');
      return;
    }

    await ref
        .read(authControllerProvider.notifier)
        .signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          accountType: selectedRole!,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
        );
  }

  Future<void> _signUpWithGoogle() async {
    if (selectedRole == null) {
      _showSnack('Please select your role');
      return;
    }

    await ref
        .read(authControllerProvider.notifier)
        .signUpWithGoogle(accountType: selectedRole!);
  }

  void _navigateAfterSignup(AppUser user) {
    if (!mounted) return;
    final String role = user.accountType.toLowerCase();
    Widget destination;
    if (role == 'entrepreneur') {
      destination = const AddProject();
    } else {
      destination = const ProjectsScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute<Widget>(builder: (_) => destination),
    );
    _showSnack('Account created successfully');
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.accent.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, _authListener);
    final AuthState authState = ref.watch(authControllerProvider);
    final bool isLoading = authState.maybeWhen(
      loading: (_) => true,
      orElse: () => false,
    );

    final ThemeProvider themeProvider =
        legacy_provider.Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [
                    Color(0xFF0F2027),
                    Color(0xFF203A43),
                    Color(0xFF2C5364),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : AppColors.mainGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 20,
                right: 20,
                child: IconButton(
                  icon: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () => themeProvider.toggleTheme(),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 20,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.person_add_alt_1,
                          size: 90,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'Create Your Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 25),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: _firstNameController,
                                label: 'First Name',
                                icon: Icons.badge_outlined,
                                validatorMsg: 'Enter your first name',
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                controller: _lastNameController,
                                label: 'Last Name',
                                icon: Icons.badge,
                                validatorMsg: 'Enter your last name',
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                controller: _emailController,
                                label: 'Email',
                                icon: Icons.email_outlined,
                                validatorMsg: 'Enter your email',
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                controller: _passwordController,
                                label: 'Password',
                                icon: Icons.lock_outline,
                                isPassword: true,
                                validatorMsg:
                                    'Password must be at least 6 characters',
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'I am a...',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ToggleButtons(
                                isSelected: <bool>[
                                  selectedRole == 'entrepreneur',
                                  selectedRole == 'investor',
                                ],
                                borderRadius: BorderRadius.circular(12),
                                fillColor: AppColors.accent,
                                selectedColor: AppColors.heading,
                                color: Colors.white,
                                onPressed: (int index) {
                                  setState(() {
                                    selectedRole = index == 0
                                        ? 'entrepreneur'
                                        : 'investor';
                                  });
                                },
                                children: const <Widget>[
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    child: Text(
                                      'Entrepreneur',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    child: Text(
                                      'Investor',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : ElevatedButton(
                                onPressed: _signUpWithEmail,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: AppColors.heading,
                                  shape: const StadiumBorder(),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 50,
                                    vertical: 16,
                                  ),
                                ),
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                        const SizedBox(height: 25),
                        Text(
                          'Or sign up with',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: isLoading ? null : _signUpWithGoogle,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white54),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.1),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: Image.asset(
                                    'images/7.webp',
                                    width: 28,
                                    height: 28,
                                    errorBuilder: (
                                      BuildContext context,
                                      Object error,
                                      StackTrace? stackTrace,
                                    ) =>
                                        const Icon(Icons.account_circle, size: 28),
                                  ),
                                ),
                                const Text(
                                  'Sign up with Google',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account? ',
                              style: TextStyle(color: Colors.white70),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String validatorMsg,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Colors.white),
      validator: (String? value) =>
          (value == null || value.isEmpty) ? validatorMsg : null,
    );
  }

}
