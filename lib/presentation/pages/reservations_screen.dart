import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import 'package:rakna_app/core/app_colors.dart';
import 'package:rakna_app/data/models/booking_model.dart';
import 'package:rakna_app/presentation/manager/booking_cubit.dart';
import 'package:rakna_app/presentation/manager/booking_state.dart';
import 'package:rakna_app/presentation/pages/booking_details_screen.dart';
import 'package:rakna_app/presentation/widgets/glass_container.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BookingCubit>().fetchBookings();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Text(
                'History',
                style: GoogleFonts.inter(
                  color: cs.onSurface,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<BookingCubit, BookingState>(
                builder: (context, state) {
                  if (state is BookingLoading || state is BookingInitial) {
                    return _buildSkeletonList(isDark);
                  }

                  if (state is BookingError) {
                    return _buildEmptyState(
                      cs,
                      isDark,
                      icon: Icons.error_outline,
                      title: 'Something went wrong',
                      subtitle: state.message,
                      showRetry: true,
                    );
                  }

                  if (state is BookingSuccess && state.bookings.isEmpty) {
                    return _buildEmptyState(
                      cs,
                      isDark,
                      icon: Icons.local_parking_outlined,
                      title: "Your luxury journey\nhasn't started yet",
                      subtitle:
                          'Reserve your first premium spot from the Map tab.',
                    );
                  }

                  if (state is BookingSuccess) {
                    return RefreshIndicator(
                      onRefresh: () =>
                          context.read<BookingCubit>().fetchBookings(),
                      color: cs.primary,
                      backgroundColor:
                          isDark ? const Color(0xFF1A1A1A) : Colors.white,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount: state.bookings.length,
                        itemBuilder: (context, index) {
                          final booking = state.bookings[index];
                          return _buildBookingCard(
                              context, booking, isDark, cs, index);
                        },
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingModel booking,
      bool isDark, ColorScheme cs, int index) {
    Color statusColor;
    IconData statusIcon;
    switch (booking.status.toUpperCase()) {
      case 'ACTIVE':
        statusColor = cs.primary;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'COMPLETED':
        statusColor = AppColors.gold;
        statusIcon = Icons.done_all;
        break;
      case 'CANCELLED':
        statusColor = AppColors.error;
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        statusColor = cs.secondary;
        statusIcon = Icons.info_outline;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 80)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GlassContainer(
          borderRadius: BorderRadius.circular(18),
          padding: const EdgeInsets.all(16),
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookingDetailsScreen(booking: booking),
              ),
            );
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(statusIcon, color: statusColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.mallName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: cs.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(booking.timestamp),
                      style: GoogleFonts.inter(
                        color: cs.secondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${booking.price.toStringAsFixed(0)} EGP',
                    style: GoogleFonts.inter(
                      color: cs.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      booking.status.toUpperCase(),
                      style: GoogleFonts.inter(
                        color: statusColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right,
                  color: cs.secondary.withValues(alpha: 0.5), size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonList(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.grey.withValues(alpha: 0.12),
      highlightColor: isDark
          ? Colors.white.withValues(alpha: 0.10)
          : Colors.grey.withValues(alpha: 0.05),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        itemCount: 5,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    ColorScheme cs,
    bool isDark, {
    required IconData icon,
    required String title,
    required String subtitle,
    bool showRetry = false,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.primary.withValues(alpha: 0.08),
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: cs.primary.withValues(alpha: 0.15),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                icon,
                color: cs.primary.withValues(alpha: 0.6),
                size: 56,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: cs.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: cs.secondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            if (showRetry) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.read<BookingCubit>().fetchBookings(),
                child: const Text('TRY AGAIN'),
              ),
            ],
          ],
        ),
      ),
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
    return '${months[date.month - 1]} ${date.day}, ${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
