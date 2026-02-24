import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rakna_app/core/app_colors.dart';

class LuxuryTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool isPassword;
  final IconData? prefixIcon;
  final TextInputType keyboardType;

  const LuxuryTextField({
    super.key,
    required this.controller,
    required this.label,
    this.isPassword = false,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<LuxuryTextField> createState() => _LuxuryTextFieldState();
}

class _LuxuryTextFieldState extends State<LuxuryTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final hintColor = isDark
        ? Colors.white.withValues(alpha: 0.6)
        : Colors.black.withValues(alpha: 0.6);
    final bgColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.05);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: _isFocused
                    ? AppColors.accent.withValues(alpha: 0.8)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.1)),
                width: 0.2,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              obscureText: widget.isPassword,
              keyboardType: widget.keyboardType,
              style: TextStyle(
                  color: textColor, fontWeight: FontWeight.w500, fontSize: 16),
              cursorColor: AppColors.accent,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: widget.label,
                labelStyle: TextStyle(
                  color: hintColor,
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                        widget.prefixIcon,
                        color: _isFocused ? AppColors.accent : hintColor,
                        size: 20,
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
