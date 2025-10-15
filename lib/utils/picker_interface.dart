// Simple stub for picked image representation.
// This file intentionally avoids importing platform-specific picker packages.

class PickedImage {
  final List<int>? bytes;
  final String? path;
  final String? filename;
  final bool isWeb;

  PickedImage({this.bytes, this.path, this.filename, required this.isWeb});
}

typedef PickImageFn = Future<PickedImage?> Function();
