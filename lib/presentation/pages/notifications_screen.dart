import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rakna_app/core/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _bookingAlerts = true;
  bool _promotions = false;
  bool _securityAlerts = true;
  bool _priceDrops = false;

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
          'Notifications',
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
            'PREFERENCES',
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
            icon: Icons.local_parking_outlined,
            title: 'Booking Alerts',
            subtitle: 'Confirmations, reminders, and cancellations',
            value: _bookingAlerts,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              setState(() => _bookingAlerts = v);
            },
          ),
          _buildToggleTile(
            cs: cs,
            isDark: isDark,
            icon: Icons.local_offer_outlined,
            title: 'Promotions',
            subtitle: 'Exclusive deals and loyalty rewards',
            value: _promotions,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              setState(() => _promotions = v);
            },
          ),
          _buildToggleTile(
            cs: cs,
            isDark: isDark,
            icon: Icons.shield_outlined,
            title: 'Security Alerts',
            subtitle: 'Login attempts and device changes',
            value: _securityAlerts,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              setState(() => _securityAlerts = v);
            },
          ),
          _buildToggleTile(
            cs: cs,
            isDark: isDark,
            icon: Icons.trending_down_outlined,
            title: 'Price Drops',
            subtitle: 'Alerts when nearby parking rates decrease',
            value: _priceDrops,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              setState(() => _priceDrops = v);
            },
          ),
        ],
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
                style: GoogleFonts.inter(
                  color: cs.secondary,
                  fontSize: 12,
                ),
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
}
