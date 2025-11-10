import 'dart:io';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ProfileImagePicker extends StatelessWidget {
  final File? image;
  final VoidCallback onPick;

  const ProfileImagePicker({super.key, this.image, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 65,
          backgroundImage: image != null
              ? FileImage(image!)
              : const AssetImage('images/profile.jpeg') as ImageProvider,
        ),
        Positioned(
          bottom: 0,
          right: 4,
          child: InkWell(
            onTap: onPick,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.button,
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool readOnly;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white70),
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
            borderSide: const BorderSide(color: AppColors.button, width: 1.6),
          ),
        ),
      ),
    );
  }
}
