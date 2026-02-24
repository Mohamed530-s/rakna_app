import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:rakna_app/core/app_colors.dart';
import 'package:rakna_app/core/app_theme.dart';
import 'package:rakna_app/core/marker_generator.dart';
import 'package:rakna_app/domain/entities/parking_spot.dart';
import 'package:rakna_app/presentation/manager/parking_cubit.dart';
import 'package:rakna_app/presentation/manager/parking_state.dart';
import 'package:rakna_app/presentation/widgets/booking_sheet.dart';
import 'package:rakna_app/presentation/widgets/glass_container.dart';
import 'package:rakna_app/presentation/widgets/glass_empty_state.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  LatLng _currentPosition = const LatLng(30.0444, 31.2357);
  bool _locationReady = false;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<ParkingSpot> _filteredSpots = [];
  Brightness? _lastBrightness;

  List<String>? _lastSpotIds;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentBrightness = Theme.of(context).brightness;
    if (_lastBrightness != null && _lastBrightness != currentBrightness) {
      _mapController?.setMapStyle(
        currentBrightness == Brightness.dark
            ? AppTheme.darkMapStyle
            : AppTheme.silverMapStyle,
      );

      MarkerGenerator.clearCache();
    }
    _lastBrightness = currentBrightness;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    final status = await Permission.location.request();
    if (!mounted) return;

    if (status.isDenied || status.isPermanentlyDenied) {
      if (mounted) _showLocationPermissionSheet();
      _loadMalls(_currentPosition.latitude, _currentPosition.longitude);
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _locationReady = true;
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition, 12),
      );
      _loadMalls(position.latitude, position.longitude);
    } catch (e) {
      if (!mounted) return;
      _loadMalls(_currentPosition.latitude, _currentPosition.longitude);
    }
  }

  void _loadMalls(double lat, double lng) {
    if (!mounted) return;
    context.read<ParkingCubit>().fetchNearbyMalls(lat, lng);
  }

  Future<void> _buildMarkers(List<ParkingSpot> spots) async {
    final ids = spots.map((s) => '${s.id}_${s.status}').toList();
    if (_lastSpotIds != null &&
        ids.length == _lastSpotIds!.length &&
        ids.every((id) => _lastSpotIds!.contains(id))) {
      return;
    }

    final availableIcon = await MarkerGenerator.createCustomMarkerBitmap(true);
    if (!mounted) return;
    final fullIcon = await MarkerGenerator.createCustomMarkerBitmap(false);
    if (!mounted) return;

    final markers = <Marker>{};
    for (final spot in spots) {
      markers.add(Marker(
        markerId: MarkerId(spot.id),
        position: LatLng(spot.latitude, spot.longitude),
        icon: spot.status == 'available' ? availableIcon : fullIcon,
        infoWindow: InfoWindow(title: spot.label),
        onTap: () => _showSpotSheet(spot),
      ));
    }

    if (!mounted) return;
    _lastSpotIds = ids;
    setState(() => _markers
      ..clear()
      ..addAll(markers));
  }

  void _showSpotSheet(ParkingSpot spot) {
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.42,
        maxChildSize: 0.7,
        minChildSize: 0.3,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            color: isDark ? const Color(0xFF141414) : Colors.white,
            border: Border(
              top: BorderSide(
                color: cs.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withValues(alpha: isDark ? 0.15 : 0.05),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
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
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        spot.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: cs.onSurface,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: spot.status == 'available'
                            ? cs.primary.withValues(alpha: 0.12)
                            : AppColors.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: spot.status == 'available'
                              ? cs.primary.withValues(alpha: 0.4)
                              : AppColors.error.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        spot.status == 'available' ? 'AVAILABLE' : 'FULL',
                        style: GoogleFonts.inter(
                          color: spot.status == 'available'
                              ? cs.primary
                              : AppColors.error,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        color: cs.secondary, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        spot.address.isEmpty ? 'Cairo, Egypt' : spot.address,
                        style: GoogleFonts.inter(
                          color: cs.secondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.near_me_outlined, color: cs.secondary, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '${(spot.distanceInMeters / 1000).toStringAsFixed(1)} km',
                      style:
                          GoogleFonts.inter(color: cs.secondary, fontSize: 13),
                    ),
                    const SizedBox(width: 16),
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
                const SizedBox(height: 28),
                if (spot.status == 'available')
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        HapticFeedback.heavyImpact();
                        if (!mounted) return;
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
                      child: Text(
                        'RESERVE SPOT',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: null,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: AppColors.error.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        spot.estimatedFreeTime != null
                            ? 'Available ~${spot.estimatedFreeTime!.difference(DateTime.now()).inMinutes} min'
                            : 'NO SPOTS AVAILABLE',
                        style: GoogleFonts.inter(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLocationPermissionSheet() {
    if (!mounted) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off_outlined, color: cs.primary, size: 48),
            const SizedBox(height: 16),
            Text(
              "Location Required",
              style: GoogleFonts.inter(
                color: cs.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Rakna needs your location to find nearby parking. We never store your location data.",
              style: GoogleFonts.inter(
                color: cs.onSurface.withValues(alpha: 0.6),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text("OPEN SETTINGS"),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Use Default Location",
                style: GoogleFonts.inter(color: cs.secondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _filterSpots(String query, List<ParkingSpot> allSpots) {
    setState(() {
      if (query.isEmpty) {
        _filteredSpots = [];
      } else {
        _filteredSpots = allSpots
            .where((s) =>
                s.label.toLowerCase().contains(query.toLowerCase()) ||
                s.address.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _focusOnSpot(ParkingSpot spot) {
    _searchController.clear();
    setState(() {
      _filteredSpots = [];
      _isSearching = false;
    });
    FocusScope.of(context).unfocus();

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(spot.latitude, spot.longitude),
        15,
      ),
    );

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _showSpotSheet(spot);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocConsumer<ParkingCubit, ParkingState>(
        listener: (context, state) {
          if (state is ParkingLoaded) {
            _buildMarkers(state.spots);
          }
        },
        builder: (context, state) {
          List<ParkingSpot> allSpots = [];
          if (state is ParkingLoaded) {
            allSpots = state.spots;
          }

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentPosition,
                  zoom: 11,
                ),
                markers: _markers,
                myLocationEnabled: _locationReady,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                onMapCreated: (controller) {
                  _mapController = controller;
                  controller.setMapStyle(
                    isDark ? AppTheme.darkMapStyle : AppTheme.silverMapStyle,
                  );
                },
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.5)
                                  : Colors.white.withValues(alpha: 0.85),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : AppColors.lightBorder,
                                width: 0.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? Colors.black.withValues(alpha: 0.3)
                                      : Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              style: GoogleFonts.inter(
                                color: cs.onSurface,
                                fontSize: 15,
                              ),
                              cursorColor: cs.primary,
                              onChanged: (q) => _filterSpots(q, allSpots),
                              onTap: () => setState(() => _isSearching = true),
                              decoration: InputDecoration(
                                hintText: 'Search malls...',
                                hintStyle: GoogleFonts.inter(
                                  color: cs.onSurface.withValues(alpha: 0.35),
                                  fontSize: 15,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: cs.onSurface.withValues(alpha: 0.4),
                                  size: 22,
                                ),
                                suffixIcon: _isSearching
                                    ? GestureDetector(
                                        onTap: () {
                                          _searchController.clear();
                                          FocusScope.of(context).unfocus();
                                          setState(() {
                                            _isSearching = false;
                                            _filteredSpots = [];
                                          });
                                        },
                                        child: Icon(Icons.close,
                                            color: cs.secondary, size: 20),
                                      )
                                    : null,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (_filteredSpots.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          constraints: const BoxConstraints(maxHeight: 220),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: isDark
                                      ? Colors.black.withValues(alpha: 0.7)
                                      : Colors.white.withValues(alpha: 0.9),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : AppColors.lightBorder,
                                    width: 0.5,
                                  ),
                                ),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.all(8),
                                  itemCount: _filteredSpots.length,
                                  separatorBuilder: (_, __) => Divider(
                                    height: 1,
                                    color: cs.outline.withValues(alpha: 0.15),
                                  ),
                                  itemBuilder: (_, i) {
                                    final s = _filteredSpots[i];
                                    return ListTile(
                                      dense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 2),
                                      leading: Icon(
                                        Icons.place_outlined,
                                        color: cs.primary,
                                        size: 20,
                                      ),
                                      title: Text(
                                        s.label,
                                        style: GoogleFonts.inter(
                                          color: cs.onSurface,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${(s.distanceInMeters / 1000).toStringAsFixed(1)} km',
                                        style: GoogleFonts.inter(
                                          color: cs.secondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                      onTap: () => _focusOnSpot(s),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (state is ParkingLoading)
                Center(
                  child: GlassContainer(
                    padding: const EdgeInsets.all(24),
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: cs.primary,
                          strokeWidth: 2,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Scanning area...',
                          style: GoogleFonts.inter(
                            color: cs.onSurface,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (state is ParkingError)
                GlassEmptyState(
                  icon: Icons.wifi_off_rounded,
                  title: 'Connection Issue',
                  subtitle: state.message,
                  onRetry: () => _loadMalls(
                    _currentPosition.latitude,
                    _currentPosition.longitude,
                  ),
                ),
              Positioned(
                bottom: 100,
                right: 20,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _mapController?.animateCamera(
                      CameraUpdate.newLatLngZoom(_currentPosition, 12),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.white.withValues(alpha: 0.85),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.10)
                                : AppColors.lightBorder,
                            width: 0.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.3)
                                  : Colors.black.withValues(alpha: 0.06),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.my_location,
                          color: cs.primary,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
