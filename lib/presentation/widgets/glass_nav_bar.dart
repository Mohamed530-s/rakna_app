import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:rakna_app/core/app_colors.dart';

class GlassNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChange;
  final bool isVisible;

  const GlassNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return AnimatedSlide(
      offset: isVisible ? Offset.zero : const Offset(0, 1.5),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white.withValues(alpha: 0.70),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.10)
                        : const Color(0xFFEEEEEE),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: 0.06),
                      blurRadius: 20,
                      spreadRadius: isDark ? 3 : 0,
                    ),
                  ],
                ),
                child: GNav(
                  gap: 8,
                  activeColor: cs.primary,
                  tabBackgroundColor: cs.primary.withValues(alpha: 0.12),
                  iconSize: 22,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.4)
                      : AppColors.lightTextSecondary,
                  textStyle: GoogleFonts.inter(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  selectedIndex: selectedIndex,
                  onTabChange: (index) {
                    HapticFeedback.selectionClick();
                    onTabChange(index);
                  },
                  tabs: const [
                    GButton(icon: Icons.map_outlined, text: 'Map'),
                    GButton(icon: Icons.explore_outlined, text: 'Explore'),
                    GButton(icon: Icons.receipt_long_outlined, text: 'History'),
                    GButton(icon: Icons.person_outline, text: 'Profile'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
