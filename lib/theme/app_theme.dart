import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  static const bg         = Color(0xFF000000);
  static const card       = Color(0xFF1C1C1E);
  static const cardHover  = Color(0xFF242426);
  static const elevated   = Color(0xFF2C2C2E);
  static const text       = Color(0xFFFFFFFF);
  static const textSub    = Color(0xFF8E8E93);
  static const textTert   = Color(0xFF636366);
  static const accent     = Color(0xFFFFFFFF);
  static const track      = Color(0xFF3A3A3C);
  static const separator  = Color(0xFF38383A);
  static const destructive = Color(0xFFFF453A);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.bg,
      surfaceContainerHighest: AppColors.card,
      primary: AppColors.text,
      onPrimary: AppColors.bg,
      secondary: AppColors.textSub,
      error: AppColors.destructive,
      onSurface: AppColors.text,
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.text, fontSize: 34,
        fontWeight: FontWeight.w700, letterSpacing: -0.5),
      headlineMedium: TextStyle(
        color: AppColors.text, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      headlineSmall: TextStyle(
        color: AppColors.text, fontWeight: FontWeight.w700),
      titleLarge: TextStyle(
        color: AppColors.text, fontSize: 17, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(
        color: AppColors.text, fontSize: 15, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: AppColors.text, fontSize: 15),
      bodyMedium: TextStyle(color: AppColors.textSub, fontSize: 13),
      bodySmall: TextStyle(color: AppColors.textSub, fontSize: 11),
      labelSmall: TextStyle(
        color: AppColors.textSub, fontSize: 11, letterSpacing: 0.5),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.elevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.text, width: 1),
      ),
      labelStyle: const TextStyle(color: AppColors.textSub),
      hintStyle: const TextStyle(color: AppColors.textTert),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.card,
      surfaceTintColor: Colors.transparent,
      modalElevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.elevated,
      selectedColor: AppColors.text,
      labelStyle: const TextStyle(color: AppColors.text, fontSize: 13),
      secondaryLabelStyle: const TextStyle(color: AppColors.bg, fontSize: 13),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.separator, thickness: 0.5, space: 0),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.elevated,
      contentTextStyle: const TextStyle(color: AppColors.text),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(AppColors.card),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    ),
    useMaterial3: true,
  );
}
