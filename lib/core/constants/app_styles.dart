import 'package:flutter/material.dart';

/// Centralized UI dimensions, paddings, and border radius tokens.
class AppStyles {
  AppStyles._();

  // Padding & Spacing
  static const double p4 = 4.0;
  static const double p8 = 8.0;
  static const double p12 = 12.0;
  static const double p16 = 16.0;
  static const double p20 = 20.0;
  static const double p24 = 24.0;

  // Border Radii
  static final BorderRadius radiusSmall = BorderRadius.circular(6.0);
  static final BorderRadius radiusMedium = BorderRadius.circular(10.0);
  static final BorderRadius radiusLarge = BorderRadius.circular(16.0);

  // Common Card BoxShadow
  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withAlpha(10),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];
}
