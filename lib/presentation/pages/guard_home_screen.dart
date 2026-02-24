import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rakna_app/core/app_colors.dart';
import 'package:rakna_app/presentation/manager/booking_cubit.dart';
import 'package:rakna_app/presentation/manager/auth_cubit.dart';
import 'package:rakna_app/presentation/widgets/glass_container.dart';

class GuardHomeScreen extends StatefulWidget {
  const GuardHomeScreen({super.key});

  @override
  State<GuardHomeScreen> createState() => _GuardHomeScreenState();
}

class _GuardHomeScreenState extends State<GuardHomeScreen>
    with SingleTickerProviderStateMixin {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;
  bool _isProcessing = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _checkPermission();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      if (mounted) _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.camera_alt, color: cs.error, size: 50),
              const SizedBox(height: 20),
              Text(
                "Camera Required",
                style: GoogleFonts.inter(
                  color: cs.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "To verify tickets, Rakna needs camera access.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: cs.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => openAppSettings(),
                  child: const Text("OPEN SETTINGS"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (!_isScanning || _isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null) return;

    HapticFeedback.heavyImpact();

    setState(() {
      _isProcessing = true;
      _isScanning = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
          strokeWidth: 2,
        ),
      ),
    );

    final result = await context.read<BookingCubit>().verifyAccess(code);

    if (mounted) {
      Navigator.pop(context);
      _showResultDialog(result);
    }
  }

  void _showResultDialog(Map<String, dynamic> result) {
    final cs = Theme.of(context).colorScheme;
    final bool isValid = result['valid'] == true;
    final String message = result['message'] ?? 'Unknown';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElasticIn(
                child: Icon(
                  isValid ? Icons.check_circle : Icons.cancel,
                  color: isValid ? cs.primary : AppColors.error,
                  size: 72,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isValid ? "Access Granted" : "Entry Denied",
                style: GoogleFonts.inter(
                  color: isValid ? cs.primary : AppColors.error,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: cs.onSurface.withValues(alpha: 0.7),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isValid ? cs.primary : AppColors.error,
                    foregroundColor: isValid ? cs.onPrimary : Colors.white,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    setState(() {
                      _isProcessing = false;
                      _isScanning = true;
                    });
                  },
                  child: Text(
                    "SCAN NEXT",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Guard Scanner",
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: AppColors.error),
            onPressed: () {
              HapticFeedback.mediumImpact();
              context.read<AuthCubit>().logout();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),
          Center(
            child: FadeTransition(
              opacity:
                  Tween<double>(begin: 0.5, end: 1.0).animate(_pulseController),
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: cs.primary, width: 2),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Text(
              "Align QR Code within frame",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                shadows: [
                  const Shadow(color: Colors.black, blurRadius: 6),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
