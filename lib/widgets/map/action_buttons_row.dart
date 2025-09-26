import 'package:flutter/material.dart';

class ActionButtonsRow extends StatelessWidget {
  final VoidCallback? onCallPressed;
  final VoidCallback? onMessagePressed;
  final VoidCallback? onMorePressed;

  const ActionButtonsRow({
    super.key,
    this.onCallPressed,
    this.onMessagePressed,
    this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Call button
        Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: IconButton(
            onPressed: onCallPressed ?? () {
              // Call phone
              print('Calling...');
            },
            icon: const Icon(
              Icons.phone,
              color: Colors.black,
              size: 24,
            ),
            iconSize: 24,
            padding: const EdgeInsets.all(12),
          ),
        ),
        
        // Message button
        Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: IconButton(
            onPressed: onMessagePressed ?? () {
              // Send message
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.message,
              color: Colors.black,
              size: 24,
            ),
            iconSize: 24,
            padding: const EdgeInsets.all(12),
          ),
        ),
        
        // More options button
        Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: IconButton(
            onPressed: onMorePressed ?? () {
              // More options
              print('More options...');
            },
            icon: const Icon(
              Icons.more_horiz,
              color: Colors.black,
              size: 24,
            ),
            iconSize: 24,
            padding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }
}