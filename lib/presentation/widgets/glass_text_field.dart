import 'package:flutter/material.dart';
import 'package:rakna_app/core/app_colors.dart';
import 'package:rakna_app/presentation/widgets/glass_container.dart';

class GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  final IconData? prefixIcon;
  final TextInputType keyboardType;

  const GlassTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.isPassword = false,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      margin: const EdgeInsets.only(bottom: 16),
      borderRadius: BorderRadius.circular(12),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        cursorColor: AppColors.accent,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
          ),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: AppColors.accent.withValues(alpha: 0.8))
              : null,
        ),
      ),
    );
  }
}
