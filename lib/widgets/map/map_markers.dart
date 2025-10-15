import 'package:flutter/material.dart';

class MapMarkers extends StatelessWidget {
  const MapMarkers({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Destination marker
        const Positioned(
          top: 200,
          left: 150,
          child: Icon(
            Icons.location_pin,
            color: Colors.red,
            size: 40,
          ),
        ),
        // User location marker (blue dot)
        const Positioned(
          bottom: 300,
          left: 100,
          child: CircleAvatar(
            radius: 8,
            backgroundColor: Colors.blue,
            child: CircleAvatar(
              radius: 6,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 4,
                backgroundColor: Colors.blue,
              ),
            ),
          ),
        ),
      ],
    );
  }
}