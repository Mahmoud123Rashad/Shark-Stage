import 'dart:io';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ProfileImagePicker extends StatelessWidget {
  final File? image;
  final String? imageUrl;
  final VoidCallback onPick;
  final bool isUploading;

  const ProfileImagePicker({
    super.key,
    this.image,
    this.imageUrl,
    required this.onPick,
    this.isUploading = false,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? backgroundImage;
    if (image != null) {
      backgroundImage = FileImage(image!);
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      backgroundImage = NetworkImage(imageUrl!);
    } else {
      backgroundImage = const AssetImage('images/profile.jpeg') as ImageProvider;
    }

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 65,
          backgroundColor: Colors.white.withOpacity(0.1),
          backgroundImage: backgroundImage,
          child: isUploading
              ? Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 4,
          child: InkWell(
            onTap: isUploading ? null : onPick,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isUploading
                    ? Colors.grey
                    : AppColors.button,
              ),
              child: Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
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
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.readOnly = false,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        validator: validator,
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.6),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.6),
          ),
          errorStyle: const TextStyle(color: Colors.redAccent),
        ),
      ),
    );
  }
}
