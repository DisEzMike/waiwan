import 'package:flutter/material.dart';
import 'map_controls.dart';
import 'map_markers.dart';

class MapContainer extends StatelessWidget {
  final VoidCallback? onLocationPressed;
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final Widget? customMapWidget;

  const MapContainer({
    super.key,
    this.onLocationPressed,
    this.onZoomIn,
    this.onZoomOut,
    this.customMapWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Map placeholder or custom map widget
            customMapWidget ?? Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
              child: const Center(
                child: Text(
                  'Map API will be integrated here',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            // Map overlay elements
            MapControls(
              onLocationPressed: onLocationPressed,
              onZoomIn: onZoomIn,
              onZoomOut: onZoomOut,
            ),
            const MapMarkers(),
          ],
        ),
      ),
    );
  }
}