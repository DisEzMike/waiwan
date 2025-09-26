import 'package:flutter/material.dart';

class MapControls extends StatelessWidget {
  final VoidCallback? onLocationPressed;
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;

  const MapControls({
    super.key,
    this.onLocationPressed,
    this.onZoomIn,
    this.onZoomOut,
  });

  @override
  Widget build(BuildContext context) {
    // MapControls now empty - location and zoom controls moved to separate widgets
    return const SizedBox.shrink();
  }
}