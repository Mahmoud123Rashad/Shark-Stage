import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class SignUpInputField extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final bool isPassword;
  final String validatorMsg;
  final Color fillColor;
  final TextStyle labelStyle;

  const SignUpInputField({
    super.key,
    required this.icon,
    required this.label,
    required this.controller,
    this.isPassword = false,
    required this.validatorMsg,
    required this.fillColor,
    required this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
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
