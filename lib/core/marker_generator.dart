import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rakna_app/core/app_colors.dart';

class MarkerGenerator {
  static BitmapDescriptor? _availableMarker;
  static BitmapDescriptor? _fullMarker;

  static Future<BitmapDescriptor> createCustomMarkerBitmap(
      bool isAvailable) async {
    if (isAvailable && _availableMarker != null) return _availableMarker!;
    if (!isAvailable && _fullMarker != null) return _fullMarker!;

    final bitmap = await _render(isAvailable);

    if (isAvailable) {
      _availableMarker = bitmap;
    } else {
      _fullMarker = bitmap;
    }
    return bitmap;
  }

  static void clearCache() {
    _availableMarker = null;
    _fullMarker = null;
  }

  static Future<BitmapDescriptor> _render(bool isAvailable) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    const int size = 120;
    const double center = size / 2.0;

    final Paint glowPaint = Paint()
      ..color = (isAvailable ? AppColors.accent : AppColors.error)
          .withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15.0);

    canvas.drawCircle(const Offset(center, center), size / 3, glowPaint);

    final Paint silverPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(size.toDouble(), size.toDouble()),
        [Colors.white, AppColors.secondary],
      );

    canvas.drawCircle(const Offset(center, center), size / 4, silverPaint);

    final Paint centerPaint = Paint()
      ..color = isAvailable ? AppColors.accent : AppColors.error
      ..style = PaintingStyle.fill;

    canvas.drawCircle(const Offset(center, center), size / 8, centerPaint);

    final ui.Image image =
        await pictureRecorder.endRecording().toImage(size, size);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      return BitmapDescriptor.defaultMarker;
    }

    return BitmapDescriptor.bytes(byteData.buffer.asUint8List());
  }
}
