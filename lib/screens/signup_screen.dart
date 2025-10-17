import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import 'entrepreneur_dashboard.dart';
import 'projects_screen.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const SignUpScreen({super.key, required this.onToggleTheme});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? selectedRole;
  bool _isLoading = false;

  // Sign up with email
  Future<void> _signUpWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedRole == null) {
      _showSnack("Please select your role");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = userCredential.user;

      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'email': _emailController.text.trim(),
        'role': selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showSnack("Account created successfully ");

      if (selectedRole == 'Entrepreneur') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const EntrepreneurDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProjectsScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showSnack("Error: ${e.message}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  //  Sign in with Google
  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user!.uid);

      final snapshot = await userDoc.get();

      String role;

      if (!snapshot.exists) {
        role = await _selectRoleDialog();
        await userDoc.set({
          'email': user.email,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        role = snapshot['role'];
      }

      if (role == 'Entrepreneur') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const EntrepreneurDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProjectsScreen()),
        );
      }

      _showSnack("Signed in with Google ");
    } catch (e) {
      _showSnack("Google Sign-In failed: $e");
    }
  }

  Future<String> _selectRoleDialog() async {
    String selected = "Investor";
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select your role"),
          content: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: const Text("Entrepreneur"),
                  value: "Entrepreneur",
                  groupValue: selected,
                  onChanged: (value) => setState(() => selected = value!),
                ),
                RadioListTile<String>(
                  title: const Text("Investor"),
                  value: "Investor",
                  groupValue: selected,
                  onChanged: (value) => setState(() => selected = value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(selected),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.button.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
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
                  onPressed: widget.onToggleTheme,
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_add_alt_1, size: 90, color: Colors.white),
                        const SizedBox(height: 15),
                        const Text(
                          "Create Your Account",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Box
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: _emailController,
                                label: "Email",
                                icon: Icons.email_outlined,
                                validatorMsg: "Enter your email",
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                controller: _passwordController,
                                label: "Password",
                                icon: Icons.lock_outline,
                                isPassword: true,
                                validatorMsg:
                                    "Password must be at least 6 characters",
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "I am a...",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 10),

                              ToggleButtons(
                                isSelected: [
                                  selectedRole == "Entrepreneur",
                                  selectedRole == "Investor",
                                ],
                                borderRadius: BorderRadius.circular(12),
                                fillColor: AppColors.button,
                                selectedColor: AppColors.heading,
                                color: Colors.white,
                                onPressed: (index) {
                                  setState(() {
                                    selectedRole =
                                        index == 0 ? "Entrepreneur" : "Investor";
                                  });
                                },
                                children: const [
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    child: Text("presence owner", style: TextStyle(fontSize: 16)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    child: Text("Investor", style: TextStyle(fontSize: 16)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : ElevatedButton(
                                onPressed: _signUpWithEmail,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.button,
                                  foregroundColor: AppColors.heading,
                                  shape: const StadiumBorder(),
                                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                                ),
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                        const SizedBox(height: 25),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _socialButton('images/6.webp', _signInWithGoogle),
                            const SizedBox(width: 20),
                            _socialButton('images/7.webp', () {}),
                          ],
                        ),

                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Already have an account? ",
                              style: TextStyle(color: Colors.white70),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                  color: AppColors.button,
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
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Colors.white),
      validator: (value) =>
          (value == null || value.isEmpty) ? validatorMsg : null,
    );
  }

  Widget _socialButton(String image, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 65,
        height: 65,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Image.asset(image),
      ),
    );
  }
}
