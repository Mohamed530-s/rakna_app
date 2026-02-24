import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.primary,
    primaryColor: AppColors.primary,
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.primary,
      primary: AppColors.accent,
      secondary: AppColors.secondary,
      onSurface: Colors.white,
      onPrimary: Colors.black,
      error: AppColors.error,
      tertiary: AppColors.accentGlow,
      outline: AppColors.glassBorder,
      surfaceContainerHighest: AppColors.primaryDark,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          letterSpacing: 1.5,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      border: InputBorder.none,
      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF1A1A1A),
      contentTextStyle: GoogleFonts.inter(color: Colors.white, fontSize: 14),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.white.withValues(alpha: 0.08),
      thickness: 0.5,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.accent;
        return Colors.grey;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.accent.withValues(alpha: 0.3);
        }
        return Colors.grey.withValues(alpha: 0.3);
      }),
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightSurface,
    primaryColor: AppColors.lightSurface,
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      surface: AppColors.lightSurface,
      primary: AppColors.accentDeep,
      secondary: AppColors.lightTextSecondary,
      onSurface: AppColors.lightText,
      onPrimary: Colors.white,
      error: AppColors.error,
      tertiary: AppColors.accentDeep,
      outline: AppColors.lightBorder,
      surfaceContainerHighest: AppColors.lightCard,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        color: AppColors.lightText,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: AppColors.lightText),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentDeep,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          letterSpacing: 1.5,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      border: InputBorder.none,
      labelStyle: TextStyle(color: AppColors.lightText.withValues(alpha: 0.5)),
      hintStyle: TextStyle(color: AppColors.lightText.withValues(alpha: 0.4)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.lightCard,
      contentTextStyle:
          GoogleFonts.inter(color: AppColors.lightText, fontSize: 14),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.lightBorder,
      thickness: 0.5,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.accentDeep;
        return Colors.grey;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.accentDeep.withValues(alpha: 0.3);
        }
        return Colors.grey.withValues(alpha: 0.3);
      }),
    ),
  );

  static const String darkMapStyle = '''[
  {"elementType":"geometry","stylers":[{"color":"#212121"}]},
  {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},
  {"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#757575"}]},
  {"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},
  {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#181818"}]},
  {"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#2c2c2c"}]},
  {"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#373737"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3c3c3c"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]}
  ]''';

  static const String silverMapStyle = '''[
  {"elementType":"geometry","stylers":[{"color":"#f5f5f5"}]},
  {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#f5f5f5"}]},
  {"featureType":"administrative.land_parcel","elementType":"labels.text.fill","stylers":[{"color":"#bdbdbd"}]},
  {"featureType":"poi","elementType":"geometry","stylers":[{"color":"#eeeeee"}]},
  {"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},
  {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#e5e5e5"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#ffffff"}]},
  {"featureType":"road.arterial","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#dadada"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#c9c9c9"}]}
  ]''';
}
