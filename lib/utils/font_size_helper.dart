import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/font_size_provider.dart';

class FontSizeHelper {
  // Helper method to get scaled font size directly using global instance
  static double getScaledFontSize(double fontSize) {
    return FontSizeProvider.instance.getScaledFontSize(fontSize);
  }

  // Helper method to create text style with scaled font size using global instance
  static TextStyle createTextStyle({
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontSize: FontSizeProvider.instance.getScaledFontSize(fontSize),
      fontWeight: fontWeight,
      color: color,
      height: height,
      decoration: decoration,
    );
  }

  // Helper method with context (for Provider compatibility)
  static TextStyle createTextStyleWithContext(
    BuildContext context, {
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    TextDecoration? decoration,
  }) {
    final fontProvider = Provider.of<FontSizeProvider>(context, listen: false);
    return TextStyle(
      fontSize: fontProvider.getScaledFontSize(fontSize),
      fontWeight: fontWeight,
      color: color,
      height: height,
      decoration: decoration,
    );
  }

  // Common text styles with scaling using global instance
  static TextStyle get headlineLarge => createTextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get headlineMedium => createTextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get headlineSmall => createTextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get bodyLarge => createTextStyle(
    fontSize: 16,
  );

  static TextStyle get bodyMedium => createTextStyle(
    fontSize: 14,
  );

  static TextStyle get bodySmall => createTextStyle(
    fontSize: 12,
  );

  static TextStyle get labelLarge => createTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get labelMedium => createTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get labelSmall => createTextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );
}