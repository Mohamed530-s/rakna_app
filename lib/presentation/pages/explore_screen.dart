import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import 'package:rakna_app/core/app_colors.dart';
import 'package:rakna_app/domain/entities/parking_spot.dart';
import 'package:rakna_app/presentation/manager/parking_cubit.dart';
import 'package:rakna_app/presentation/manager/parking_state.dart';
import 'package:rakna_app/presentation/widgets/booking_sheet.dart';
import 'package:rakna_app/presentation/widgets/glass_container.dart';
import 'package:rakna_app/presentation/widgets/glass_empty_state.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Text(
                'Explore',
                style: GoogleFonts.inter(
                  color: cs.onSurface,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Discover premium parking near you',
                style: GoogleFonts.inter(
                  color: cs.secondary,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.white,
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : AppColors.lightBorder,
                    width: 0.5,
                  ),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                          ),
                        ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (q) => setState(() => _searchQuery = q),
                  style: GoogleFonts.inter(color: cs.onSurface, fontSize: 14),
                  cursorColor: cs.primary,
                  decoration: InputDecoration(
                    hintText: 'Search malls...',
                    hintStyle: GoogleFonts.inter(
                      color: cs.onSurface.withValues(alpha: 0.3),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(Icons.search,
                        color: cs.onSurface.withValues(alpha: 0.35), size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            child: Icon(Icons.close,
                                color: cs.secondary, size: 18),
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BlocBuilder<ParkingCubit, ParkingState>(
                builder: (context, state) {
                  if (state is ParkingLoading) {
                    return _buildShimmerList(isDark);
                  }

                  if (state is ParkingError) {
                    return GlassEmptyState(
                      icon: Icons.wifi_off_rounded,
                      title: 'Failed to load malls',
                      subtitle: state.message,
                      onRetry: () {
                        if (!mounted) return;
                        context
                            .read<ParkingCubit>()
                            .fetchNearbyMalls(30.0444, 31.2357);
                      },
                    );
                  }

                  if (state is ParkingLoaded) {
                    final spots = _searchQuery.isEmpty
                        ? state.spots
                        : state.spots
                            .where((s) =>
                                s.label
                                    .toLowerCase()
                                    .contains(_searchQuery.toLowerCase()) ||
                                s.address
                                    .toLowerCase()
                                    .contains(_searchQuery.toLowerCase()))
                            .toList();

                    if (spots.isEmpty) {
                      return const GlassEmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'No Results Found',
                        subtitle: 'Try a different search term.',
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                      itemCount: spots.length,
                      itemBuilder: (context, index) {
                        return _buildMallCard(
                            context, spots[index], isDark, cs, index);
                      },
                    );
                  }

                  return const GlassEmptyState(
                    icon: Icons.explore_outlined,
                    title: 'Discover Parking',
                    subtitle:
                        'Open the Map tab to find premium parking near you.',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMallCard(BuildContext context, ParkingSpot spot, bool isDark,
      ColorScheme cs, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: GlassContainer(
          borderRadius: BorderRadius.circular(20),
          padding: EdgeInsets.zero,
          onTap: () {
            HapticFeedback.lightImpact();
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (_) => BookingSheet(
                mallId: spot.id,
                mallName: spot.label,
                basePrice: 20.0,
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: SizedBox(
                  height: 160,
                  child: CachedNetworkImage(
                    imageUrl: spot.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.grey.withValues(alpha: 0.1),
                      child: Center(
                        child: Icon(Icons.image_outlined,
                            color: cs.secondary, size: 32),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [
                                  const Color(0xFF1A1A2E),
                                  const Color(0xFF16213E),
                                ]
                              : [
                                  const Color(0xFFE8EAF6),
                                  const Color(0xFFF5F5F5),
                                ],
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.local_parking,
                                color: cs.primary.withValues(alpha: 0.5),
                                size: 40),
                            const SizedBox(height: 8),
                            Text(
                              spot.label,
                              style: GoogleFonts.inter(
                                color: cs.onSurface.withValues(alpha: 0.5),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            spot.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: cs.onSurface,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.star, color: AppColors.gold, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              spot.rating.toStringAsFixed(1),
                              style: GoogleFonts.inter(
                                color: cs.onSurface,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            color: cs.secondary, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            spot.address.isNotEmpty
                                ? spot.address
                                : 'Cairo, Egypt',
                            style: GoogleFonts.inter(
                              color: cs.secondary,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.near_me, color: cs.secondary, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${(spot.distanceInMeters / 1000).toStringAsFixed(1)} km',
                          style: GoogleFonts.inter(
                            color: cs.secondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: spot.status == 'available'
                            ? cs.primary.withValues(alpha: 0.10)
                            : AppColors.error.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        spot.status == 'available'
                            ? '● Spots Available'
                            : '● Full',
                        style: GoogleFonts.inter(
                          color: spot.status == 'available'
                              ? cs.primary
                              : AppColors.error,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerList(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.grey.withValues(alpha: 0.12),
      highlightColor: isDark
          ? Colors.white.withValues(alpha: 0.10)
          : Colors.grey.withValues(alpha: 0.05),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
        itemCount: 4,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 200,
                height: 16,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 140,
                height: 12,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
