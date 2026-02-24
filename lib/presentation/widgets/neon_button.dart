import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rakna_app/core/app_colors.dart';

class NeonButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isLoading;
  final Color? color;

  const NeonButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isLoading = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final targetColor = color ?? AppColors.accent;

    return RepaintBoundary(
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: targetColor.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: targetColor.withValues(alpha: 0.4),
                blurRadius: 40,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: targetColor.withValues(alpha: 0.8),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  text,
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
        ),
      ),
    );
  }
}
