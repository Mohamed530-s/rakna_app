import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rakna_app/core/app_colors.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _biometricLogin = false;
  bool _twoFactor = false;
  bool _locationSharing = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: cs.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Privacy & Security',
          style: GoogleFonts.inter(
            color: cs.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'AUTHENTICATION',
            style: GoogleFonts.inter(
              color: cs.secondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildToggleTile(
            cs: cs,
            isDark: isDark,
            icon: Icons.fingerprint,
            title: 'Biometric Login',
            subtitle: 'Use fingerprint or face ID to sign in',
            value: _biometricLogin,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              setState(() => _biometricLogin = v);
            },
          ),
          _buildToggleTile(
            cs: cs,
            isDark: isDark,
            icon: Icons.security_outlined,
            title: 'Two-Factor Authentication',
            subtitle: 'Additional verification on new devices',
            value: _twoFactor,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              setState(() => _twoFactor = v);
            },
          ),
          const SizedBox(height: 24),
          Text(
            'DATA & PRIVACY',
            style: GoogleFonts.inter(
              color: cs.secondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildToggleTile(
            cs: cs,
            isDark: isDark,
            icon: Icons.location_on_outlined,
            title: 'Location Sharing',
            subtitle: 'Share location to find nearby spots',
            value: _locationSharing,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              setState(() => _locationSharing = v);
            },
          ),
          const SizedBox(height: 16),
          _buildActionTile(
            cs: cs,
            isDark: isDark,
            icon: Icons.download_outlined,
            title: 'Download My Data',
            subtitle: 'Request a copy of your personal data',
            onTap: () {
              HapticFeedback.lightImpact();
              _showInfoSnackBar('Data export request submitted');
            },
          ),
          _buildActionTile(
            cs: cs,
            isDark: isDark,
            icon: Icons.delete_forever_outlined,
            title: 'Delete Account',
            subtitle: 'Permanently remove your account and data',
            isDestructive: true,
            onTap: () {
              HapticFeedback.heavyImpact();
              _showDeleteConfirmDialog(cs, isDark);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(ColorScheme cs, bool isDark) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (dCtx) => Dialog(
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
                    ? const Color(0xFF1A1A1A).withValues(alpha: 0.95)
                    : Colors.white.withValues(alpha: 0.98),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber_outlined,
                      color: AppColors.error, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Delete Account?',
                    style: GoogleFonts.inter(
                      color: cs.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This action cannot be undone. All your data, bookings, and payment methods will be permanently removed.',
                    style: GoogleFonts.inter(
                      color: cs.secondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dCtx),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: cs.outline),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text('Cancel',
                              style: GoogleFonts.inter(
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dCtx);
                            _showInfoSnackBar(
                                'Account deletion request submitted');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text('Delete',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700)),
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

  void _showInfoSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message,
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400)),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0A0A0A).withValues(alpha: 0.95),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(20),
        elevation: 0,
      ),
    );
  }

  Widget _buildToggleTile({
    required ColorScheme cs,
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
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
              subtitle: Text(
                subtitle,
                style: GoogleFonts.inter(color: cs.secondary, fontSize: 12),
              ),
              trailing: Switch.adaptive(
                value: value,
                activeColor: cs.primary,
                onChanged: onChanged,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required ColorScheme cs,
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
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
                color: isDestructive
                    ? AppColors.error.withValues(alpha: 0.15)
                    : isDark
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
                  color: isDestructive
                      ? AppColors.error.withValues(alpha: 0.08)
                      : isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon,
                    color: isDestructive ? AppColors.error : cs.onSurface,
                    size: 20),
              ),
              title: Text(
                title,
                style: GoogleFonts.inter(
                  color: isDestructive ? AppColors.error : cs.onSurface,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              subtitle: Text(
                subtitle,
                style: GoogleFonts.inter(color: cs.secondary, fontSize: 12),
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
}
