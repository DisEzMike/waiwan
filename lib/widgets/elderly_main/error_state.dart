import 'package:flutter/material.dart';

class ErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;
  final IconData icon;
  final Color iconColor;

  const ErrorState({
    super.key,
    this.title = 'ไม่สามารถเชื่อมต่อได้',
    this.message = 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้\nกรุณาตรวจสอบการเชื่อมต่อและลองใหม่',
    required this.onRetry,
    this.icon = Icons.cloud_off,
    this.iconColor = const Color(0xFF6EB715),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: iconColor,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('ลองเชื่อมต่อใหม่'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6EB715),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}