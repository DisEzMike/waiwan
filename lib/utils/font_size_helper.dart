import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/font_size_provider.dart';

class FontSizeHelper {
  // Helper method to get scaled font size directly
  static double getScaledFontSize(BuildContext context, double fontSize) {
    final fontProvider = Provider.of<FontSizeProvider>(context, listen: false);
    return fontProvider.getScaledFontSize(fontSize);
  }

  // Helper method to create text style with scaled font size
  static TextStyle createTextStyle(
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

  // Common text styles with scaling
  static TextStyle headlineLarge(BuildContext context) => createTextStyle(
    context,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static TextStyle headlineMedium(BuildContext context) => createTextStyle(
    context,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static TextStyle headlineSmall(BuildContext context) => createTextStyle(
    context,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static TextStyle bodyLarge(BuildContext context) => createTextStyle(
    context,
    fontSize: 16,
  );

  static TextStyle bodyMedium(BuildContext context) => createTextStyle(
    context,
    fontSize: 14,
  );

  static TextStyle bodySmall(BuildContext context) => createTextStyle(
    context,
    fontSize: 12,
  );

  static TextStyle labelLarge(BuildContext context) => createTextStyle(
    context,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static TextStyle labelMedium(BuildContext context) => createTextStyle(
    context,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static TextStyle labelSmall(BuildContext context) => createTextStyle(
    context,
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );
}