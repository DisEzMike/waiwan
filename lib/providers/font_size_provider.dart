import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

class FontSizeProvider extends ChangeNotifier {
  static const String _fontSizeKey = 'font_size_scale';
  double _fontSizeScale = 1.0;

  // Singleton instance
  static FontSizeProvider? _instance;
  static FontSizeProvider get instance {
    _instance ??= FontSizeProvider._internal();
    return _instance!;
  }

  // Private constructor for singleton
  FontSizeProvider._internal() {
    _loadFontSize();
  }

  // Public constructor for Provider (optional)
  FontSizeProvider() {
    _loadFontSize();
  }

  double get fontSizeScale => _fontSizeScale;

  // Load font size from localStorage
  void _loadFontSize() {
    try {
      final savedSize = localStorage.getItem(_fontSizeKey);
      if (savedSize != null) {
        _fontSizeScale = double.tryParse(savedSize.toString()) ?? 1.0;
      }
      notifyListeners();
    } catch (e) {
      print('Error loading font size: $e');
    }
  }

  // Save font size to localStorage
  void _saveFontSize() {
    try {
      localStorage.setItem(_fontSizeKey, _fontSizeScale.toString());
    } catch (e) {
      print('Error saving font size: $e');
    }
  }

  // Update font size scale
  void updateFontSize(double scale) {
    // Clamp scale to safe range to avoid layout distortion
    final clamped = scale.clamp(0.8, 1.4);
    if (clamped != _fontSizeScale) {
      _fontSizeScale = clamped;
      notifyListeners();
      _saveFontSize();
    }
  }

  // Increase font size
  void increaseFontSize() {
    if (_fontSizeScale < 1.4) {
      updateFontSize(_fontSizeScale + 0.1);
    }
  }

  // Decrease font size
  void decreaseFontSize() {
    if (_fontSizeScale > 0.8) {
      updateFontSize(_fontSizeScale - 0.1);
    }
  }

  // Reset to default
  void resetFontSize() {
    updateFontSize(1.0);
  }

  // Get scaled font size
  double getScaledFontSize(double baseSize) {
    return baseSize * _fontSizeScale;
  }

  // Get font size description
  String get fontSizeDescription {
    if (_fontSizeScale <= 0.9) return 'เล็ก';
    if (_fontSizeScale <= 1.1) return 'ปกติ';
    if (_fontSizeScale <= 1.3) return 'ใหญ่';
    return 'ใหญ่มาก';
  }
}
