import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import 'package:rakna_app/core/app_colors.dart';
import 'package:rakna_app/presentation/manager/booking_cubit.dart';
import 'package:rakna_app/presentation/manager/booking_state.dart';
import 'package:rakna_app/presentation/pages/booking_details_screen.dart';
import 'package:rakna_app/presentation/pages/payment_methods_screen.dart';

class BookingSheet extends StatefulWidget {
  final String mallId;
  final String mallName;
  final double basePrice;

  const BookingSheet({
    super.key,
    required this.mallId,
    required this.mallName,
    required this.basePrice,
  });

  @override
  State<BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<BookingSheet> {
  double _hours = 1.0;
  String _selectedPayment = 'Cash on Arrival';
  bool _showSuccess = false;
  bool _loadingPayment = true;

  double get _totalPrice => widget.basePrice * _hours;

  @override
  void initState() {
    super.initState();
    _loadSavedPaymentFromFirestore();
  }

  Future<void> _loadSavedPaymentFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loadingPayment = false);
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('payment_methods')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty && mounted) {
        final data = snapshot.docs.first.data();
        final brand = (data['brand'] as String?) ?? 'Card';
        final last4 = (data['last4'] as String?) ?? '••••';
        setState(() {
          _selectedPayment = '$brand •••• $last4';
          _loadingPayment = false;
        });
      } else {
        if (mounted) setState(() => _loadingPayment = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingPayment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        color: isDark ? const Color(0xFF141414) : Colors.white,
        border: Border(
          top: BorderSide(
            color: cs.primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: BlocConsumer<BookingCubit, BookingState>(
        listener: (context, state) {
          if (state is BookingCreated) {
            HapticFeedback.heavyImpact();
            setState(() => _showSuccess = true);

            Future.delayed(const Duration(seconds: 2), () {
              if (!context.mounted) return;
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookingDetailsScreen(booking: state.booking),
                ),
              );
            });
          }
          if (state is BookingError) {
            HapticFeedback.heavyImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.message,
                        style: GoogleFonts.inter(
                            color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.error.withValues(alpha: 0.95),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                margin: const EdgeInsets.all(20),
              ),
            );
          }
        },
        builder: (context, state) {
          if (_showSuccess) {
            return _buildSuccessAnimation(cs);
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: cs.onSurface.withValues(alpha: 0.15),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.mallName,
                  style: GoogleFonts.inter(
                    color: cs.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Secure your premium parking spot',
                  style: GoogleFonts.inter(
                    color: cs.secondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'DURATION',
                      style: GoogleFonts.inter(
                        color: cs.secondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      '${_hours.toInt()} ${_hours == 1 ? 'hour' : 'hours'}',
                      style: GoogleFonts.inter(
                        color: cs.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4,
                    activeTrackColor: cs.primary,
                    inactiveTrackColor: cs.onSurface.withValues(alpha: 0.08),
                    thumbColor: cs.primary,
                    overlayColor: cs.primary.withValues(alpha: 0.12),
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 8),
                  ),
                  child: Slider(
                    value: _hours,
                    min: 1,
                    max: 12,
                    divisions: 11,
                    onChanged: (val) {
                      HapticFeedback.selectionClick();
                      setState(() => _hours = val);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PAYMENT',
                      style: GoogleFonts.inter(
                        color: cs.secondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showPaymentPicker(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.grey.withValues(alpha: 0.08),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : AppColors.lightBorder,
                            width: 0.5,
                          ),
                        ),
                        child: _loadingPayment
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: cs.secondary,
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _selectedPayment.contains('Visa') ||
                                            _selectedPayment
                                                .contains('Mastercard')
                                        ? Icons.credit_card
                                        : Icons.payments_outlined,
                                    color: cs.onSurface,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _selectedPayment,
                                    style: GoogleFonts.inter(
                                      color: cs.onSurface,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.keyboard_arrow_down,
                                      color: cs.secondary, size: 18),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.03)
                        : Colors.grey.withValues(alpha: 0.05),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : AppColors.lightBorder,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: GoogleFonts.inter(
                          color: cs.secondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${_totalPrice.toStringAsFixed(0)} EGP',
                        style: GoogleFonts.inter(
                          color: cs.onSurface,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: state is BookingLoading
                        ? null
                        : () {
                            HapticFeedback.heavyImpact();
                            context.read<BookingCubit>().createBooking(
                                  mallId: widget.mallId,
                                  mallName: widget.mallName,
                                  basePrice: widget.basePrice,
                                  duration: _hours.toInt(),
                                  totalPrice: _totalPrice,
                                  cardUsed: _selectedPayment,
                                );
                          },
                    child: state is BookingLoading
                        ? SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: cs.onPrimary,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'CONFIRM RESERVATION',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              letterSpacing: 1.5,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSuccessAnimation(ColorScheme cs) {
    return SizedBox(
      height: 280,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Lottie.asset(
                'assets/lottie/success_check.json',
                repeat: false,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    builder: (_, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cs.primary.withValues(alpha: 0.12),
                        boxShadow: [
                          BoxShadow(
                            color: cs.primary.withValues(alpha: 0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: cs.primary,
                        size: 48,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Reservation Confirmed',
              style: GoogleFonts.inter(
                color: cs.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Loading your digital ticket...',
              style: GoogleFonts.inter(
                color: cs.secondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPaymentPicker(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final payments = <String>[];
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('payment_methods')
            .orderBy('createdAt', descending: true)
            .get();

        for (final doc in snapshot.docs) {
          final data = doc.data();
          final brand = (data['brand'] as String?) ?? 'Card';
          final last4 = (data['last4'] as String?) ?? '••••';
          payments.add('$brand •••• $last4');
        }
      } catch (_) {}
    }

    payments.add('Cash on Arrival');
    payments.add('+ Manage Cards');

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (dCtx) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isDark
                    ? const Color(0xFF1A1A1A).withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.95),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppColors.lightBorder,
                  width: 0.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SELECT PAYMENT',
                    style: GoogleFonts.inter(
                      color: cs.secondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...payments.map((p) => ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 4),
                        leading: Icon(
                          p.contains('Visa') || p.contains('Mastercard')
                              ? Icons.credit_card
                              : p.startsWith('+')
                                  ? Icons.settings_outlined
                                  : Icons.payments_outlined,
                          color: p.startsWith('+') ? cs.secondary : cs.primary,
                          size: 22,
                        ),
                        title: Text(
                          p,
                          style: GoogleFonts.inter(
                            color:
                                p.startsWith('+') ? cs.secondary : cs.onSurface,
                            fontSize: 14,
                            fontWeight: _selectedPayment == p
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                        trailing: _selectedPayment == p
                            ? Icon(Icons.check_circle,
                                color: cs.primary, size: 20)
                            : null,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        onTap: () {
                          Navigator.pop(dCtx);
                          if (p.startsWith('+')) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const PaymentMethodsScreen()),
                            ).then((_) => _loadSavedPaymentFromFirestore());
                          } else {
                            setState(() => _selectedPayment = p);
                          }
                        },
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
