import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'signup_input_field.dart';
import 'signup_buttons.dart';
import 'signup_services.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? selectedRole;
  bool _isLoading = false;

  final _services = SignUpServices();

  @override
  Widget build(BuildContext context) {
    final labelStyle = const TextStyle(color: Colors.white70);
    final panelColor = Colors.white.withOpacity(0.06);
    final inputFill = Colors.white.withOpacity(0.03);

    return Column(
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
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text("Sign up to access your dashboard", style: labelStyle),
        const SizedBox(height: 26),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: panelColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SignUpInputField(
                  icon: Icons.person,
                  label: "First Name",
                  controller: _first,
                  validatorMsg: "Please enter your first name",
                  fillColor: inputFill,
                  labelStyle: labelStyle,
                ),
                const SizedBox(height: 14),
                SignUpInputField(
                  icon: Icons.person_outline,
                  label: "Last Name",
                  controller: _last,
                  validatorMsg: "Please enter your last name",
                  fillColor: inputFill,
                  labelStyle: labelStyle,
                ),
                const SizedBox(height: 14),
                SignUpInputField(
                  icon: Icons.email_rounded,
                  label: "Email",
                  controller: _email,
                  validatorMsg: "Please enter your email",
                  fillColor: inputFill,
                  labelStyle: labelStyle,
                ),
                const SizedBox(height: 14),
                SignUpInputField(
                  icon: Icons.lock_rounded,
                  label: "Password",
                  controller: _password,
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
                    : SignUpButtons(
                        onEmailSignUp: () async {
                          if (!_formKey.currentState!.validate() || selectedRole == null) return;
                          setState(() => _isLoading = true);
                          await _services.signUpWithEmail(
                            context: context,
                            first: _first.text.trim(),
                            last: _last.text.trim(),
                            email: _email.text.trim(),
                            password: _password.text.trim(),
                            role: selectedRole!,
                          );
                          setState(() => _isLoading = false);
                        },
                        onGoogleSignUp: () async {
                          await _services.signInWithGoogle(context, selectedRole ?? "owner");
                        },
                        onLinkedInSignUp: () async {
                          await _services.signInWithLinkedIn(context, selectedRole ?? "owner");
                        },
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
