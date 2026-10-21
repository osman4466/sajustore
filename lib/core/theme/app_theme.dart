import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

/// Application theme configurations.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.primaryDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryDark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: AppStyles.radiusMedium),
          padding: const EdgeInsets.symmetric(
            vertical: AppStyles.p12,
            horizontal: AppStyles.p16,
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: AppStyles.radiusMedium),
          padding: const EdgeInsets.symmetric(
            vertical: AppStyles.p12,
            horizontal: AppStyles.p16,
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppStyles.p12,
          vertical: AppStyles.p12,
        ),
        border: OutlineInputBorder(
          borderRadius: AppStyles.radiusSmall,
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppStyles.radiusSmall,
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppStyles.radiusSmall,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: AppStyles.radiusMedium),
        margin: EdgeInsets.zero,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
