import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:rakna_app/core/app_colors.dart';
import 'package:rakna_app/presentation/manager/auth_cubit.dart';
import 'package:rakna_app/presentation/manager/auth_state.dart';
import 'package:rakna_app/presentation/manager/theme_cubit.dart';
import 'package:rakna_app/presentation/pages/edit_profile_screen.dart';
import 'package:rakna_app/presentation/pages/notifications_screen.dart';
import 'package:rakna_app/presentation/pages/payment_methods_screen.dart';
import 'package:rakna_app/presentation/pages/security_screen.dart';
import 'package:rakna_app/presentation/widgets/glass_container.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              String name = "Guest";
              String email = "—";
              String? photoUrl;

              if (state is AuthAuthenticated) {
                name = state.user.displayName ?? "User";
                email = state.user.email ?? "—";
                photoUrl = state.user.photoURL;
              }

              return Column(
                children: [
                  GlassContainer(
                    borderRadius: BorderRadius.circular(24),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: cs.primary, width: 2),
                                boxShadow: isDark
                                    ? [
                                        BoxShadow(
                                          color:
                                              cs.primary.withValues(alpha: 0.3),
                                          blurRadius: 15,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: CircleAvatar(
                                radius: 36,
                                backgroundColor: isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[200],
                                backgroundImage:
                                    photoUrl != null && photoUrl.isNotEmpty
                                        ? NetworkImage(photoUrl)
                                        : null,
                                child: photoUrl == null || photoUrl.isEmpty
                                    ? Icon(Icons.person,
                                        size: 36,
                                        color: isDark
                                            ? Colors.white
                                            : AppColors.lightTextSecondary)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      color: cs.onSurface,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      color: cs.secondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.gold
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: AppColors.gold
                                              .withValues(alpha: 0.4)),
                                    ),
                                    child: Text(
                                      'PLATINUM MEMBER',
                                      style: GoogleFonts.inter(
                                        color: AppColors.gold,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.qr_code_2,
                                color: cs.secondary, size: 38),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Divider(
                            color: cs.outline.withValues(alpha: 0.2),
                            thickness: 0.5),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'LOYALTY POINTS',
                                  style: GoogleFonts.inter(
                                    color: cs.secondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                Text(
                                  '2,450 / 5,000',
                                  style: GoogleFonts.inter(
                                    color: cs.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.06),
                              ),
                              child: Stack(
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.38,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      gradient: LinearGradient(
                                        colors: [
                                          cs.primary.withValues(alpha: 0.4),
                                          cs.primary,
                                        ],
                                      ),
                                      boxShadow: isDark
                                          ? [
                                              BoxShadow(
                                                color: cs.primary
                                                    .withValues(alpha: 0.4),
                                                blurRadius: 8,
                                              )
                                            ]
                                          : [],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildSettingTile(
                      context, Icons.person_outline, 'Edit Profile', isDark,
                      onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EditProfileScreen()),
                    );
                  }),
                  _buildSettingTile(context, Icons.payment_outlined,
                      'Payment Methods', isDark, onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PaymentMethodsScreen()),
                    );
                  }),
                  _buildSettingTile(context, Icons.notifications_none_outlined,
                      'Notifications', isDark, onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NotificationsScreen()),
                    );
                  }),
                  _buildSettingTile(context, Icons.shield_outlined,
                      'Privacy & Security', isDark, onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SecurityScreen()),
                    );
                  }),
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.03)
                                : Colors.white.withValues(alpha: 0.6),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : AppColors.lightBorder,
                              width: 0.5,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.06)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isDark
                                    ? Icons.dark_mode_outlined
                                    : Icons.light_mode_outlined,
                                color: cs.onSurface,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              'Dark Mode',
                              style: GoogleFonts.inter(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                            trailing: Switch.adaptive(
                              value: isDark,
                              activeColor: cs.primary,
                              onChanged: (val) {
                                HapticFeedback.selectionClick();
                                context.read<ThemeCubit>().toggleTheme();
                              },
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildLogoutButton(context, isDark),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile(
      BuildContext context, IconData icon, String title, bool isDark,
      {VoidCallback? onTap}) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.white.withValues(alpha: 0.6),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : AppColors.lightBorder,
                width: 0.5,
              ),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: cs.onSurface, size: 20),
              ),
              title: Text(
                title,
                style: GoogleFonts.inter(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              trailing:
                  Icon(Icons.chevron_right, color: cs.secondary, size: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              onTap: onTap,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF9B1C31),
          side: BorderSide(
            color: isDark
                ? const Color(0xFF9B1C31).withValues(alpha: 0.4)
                : const Color(0xFF9B1C31).withValues(alpha: 0.3),
            width: 1,
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: isDark
              ? const Color(0xFF9B1C31).withValues(alpha: 0.06)
              : const Color(0xFF9B1C31).withValues(alpha: 0.04),
        ),
        icon: const Icon(Icons.logout_outlined, size: 18),
        label: Text(
          'Log Out',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        onPressed: () {
          HapticFeedback.mediumImpact();
          _showLogoutConfirmation(context);
        },
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (dContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: isDark
                    ? const Color(0xFF1A1A1A).withValues(alpha: 0.85)
                    : Colors.white.withValues(alpha: 0.92),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppColors.lightBorder,
                  width: 0.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.logout_outlined, color: cs.error, size: 40),
                  const SizedBox(height: 16),
                  Text(
                    "End Session?",
                    style: GoogleFonts.inter(
                      color: cs.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "You will need to sign in again to access your account.",
                    style: GoogleFonts.inter(
                      color: cs.onSurface.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dContext),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: cs.onSurface,
                            side: BorderSide(
                                color: cs.outline.withValues(alpha: 0.3)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text('Cancel',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w500)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dContext);
                            context.read<AuthCubit>().logout();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9B1C31),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: Text('Log Out',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
