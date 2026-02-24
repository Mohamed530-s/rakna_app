import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rakna_app/core/app_colors.dart';
import 'package:rakna_app/data/models/booking_model.dart';
import 'package:rakna_app/presentation/manager/booking_cubit.dart';
import 'package:rakna_app/presentation/manager/booking_state.dart';

class BookingDetailsScreen extends StatelessWidget {
  final BookingModel booking;

  const BookingDetailsScreen({super.key, required this.booking});

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
        title: Text(
          'Digital Ticket',
          style: GoogleFonts.inter(
            color: cs.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: BackButton(color: cs.onSurface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: isDark
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1A1A1A),
                          const Color(0xFF0F0F0F),
                          cs.primary.withValues(alpha: 0.08),
                        ],
                      )
                    : const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Color(0xFFF5F5F5),
                        ],
                      ),
                border: Border.all(
                  color: isDark
                      ? cs.primary.withValues(alpha: 0.2)
                      : AppColors.lightBorder,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? cs.primary.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.04),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                    child: Column(
                      children: [
                        Text(
                          'R A K N A',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 6.0,
                            color: cs.primary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          booking.mallName,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: cs.onSurface,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isDark
                            ? [
                                BoxShadow(
                                  color: cs.primary.withValues(alpha: 0.15),
                                  blurRadius: 20,
                                  spreadRadius: 3,
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 15,
                                ),
                              ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.qr_code_2,
                              size: 100, color: Colors.black),
                          const SizedBox(height: 8),
                          Text(
                            booking.id.length >= 8
                                ? booking.id.substring(0, 8).toUpperCase()
                                : booking.id.toUpperCase(),
                            style: GoogleFonts.firaCode(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: Row(
                      children: List.generate(
                        30,
                        (i) => Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            height: 1,
                            color: cs.onSurface.withValues(alpha: 0.10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      children: [
                        _buildDetail(
                            context, 'DATE', _formatDate(booking.timestamp)),
                        const SizedBox(height: 16),
                        _buildDetail(context, 'DURATION',
                            '${booking.duration} ${booking.duration == 1 ? 'hour' : 'hours'}'),
                        const SizedBox(height: 16),
                        _buildDetail(context, 'TOTAL',
                            '${booking.totalPrice.toStringAsFixed(0)} EGP'),
                        const SizedBox(height: 16),
                        _buildDetail(context, 'PAYMENT', booking.cardUsed),
                        const SizedBox(height: 16),
                        _buildStatusDetail(context, booking.status),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            if (booking.status.toUpperCase() == 'ACTIVE')
              BlocConsumer<BookingCubit, BookingState>(
                listener: (context, state) {
                  if (state is BookingCancelled) {
                    HapticFeedback.heavyImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_outline,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'Booking cancelled successfully',
                              style: GoogleFonts.inter(
                                  color: Colors.white, fontSize: 14),
                            ),
                          ],
                        ),
                        backgroundColor: cs.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        margin: const EdgeInsets.all(20),
                      ),
                    );
                    Navigator.pop(context);
                  }
                  if (state is BookingError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF9B1C31),
                        side: BorderSide(
                          color: const Color(0xFF9B1C31).withValues(alpha: 0.4),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        backgroundColor:
                            const Color(0xFF9B1C31).withValues(alpha: 0.05),
                      ),
                      icon: state is BookingLoading
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: const Color(0xFF9B1C31),
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.cancel_outlined, size: 18),
                      label: Text(
                        state is BookingLoading
                            ? 'CANCELLING...'
                            : 'CANCEL BOOKING',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          letterSpacing: 1.0,
                        ),
                      ),
                      onPressed: state is BookingLoading
                          ? null
                          : () => _showCancelDialog(context),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail(BuildContext context, String label, String value) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: cs.secondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            color: cs.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year} at '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildStatusDetail(BuildContext context, String status) {
    final cs = Theme.of(context).colorScheme;
    Color statusColor;
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        statusColor = cs.primary;
        break;
      case 'COMPLETED':
        statusColor = AppColors.gold;
        break;
      case 'CANCELLED':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = cs.secondary;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'STATUS',
          style: GoogleFonts.inter(
            color: cs.secondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: statusColor.withValues(alpha: 0.4)),
          ),
          child: Text(
            status.toUpperCase(),
            style: GoogleFonts.inter(
              color: statusColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }

  void _showCancelDialog(BuildContext context) {
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
                  Icon(Icons.warning_amber_rounded,
                      color: const Color(0xFF9B1C31), size: 40),
                  const SizedBox(height: 16),
                  Text(
                    "Cancel Booking?",
                    style: GoogleFonts.inter(
                      color: cs.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "This will release your reserved spot. This action cannot be undone.",
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
                          child: Text('Keep',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w500)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dContext);
                            context
                                .read<BookingCubit>()
                                .cancelBooking(booking.id, booking.mallId);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9B1C31),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: Text('Cancel',
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
