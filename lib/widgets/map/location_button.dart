import 'package:flutter/material.dart';

class LocationButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const LocationButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(right: 16, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: onPressed ?? () {
            // Center on user location
            print('Center on location');
          },
          icon: const Icon(
            Icons.map,
            color: Colors.black,
            size: 24,
          ),
          iconSize: 24,
          padding: const EdgeInsets.all(12),
        ),
      ),
    );
  }
}