import '../providers/font_size_provider.dart';

class ImageSizeHelper {
  // Base sizes chosen for default scale=1.0. Multiply by font scale for accessibility.
  static double avatarRadius(double base) {
    final scale = FontSizeProvider.instance.fontSizeScale.clamp(0.8, 1.4);
    return scale * base;
  }
}
