import 'package:flutter/material.dart';

class AttachmentOptionsSheet extends StatelessWidget {
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;
  final VoidCallback onFilePressed;

  const AttachmentOptionsSheet({
    super.key,
    required this.onCameraPressed,
    required this.onGalleryPressed,
    required this.onFilePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'เลือกไฟล์แนบ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Camera option
              _buildAttachmentOption(
                icon: Icons.camera_alt,
                label: 'กล้อง',
                onTap: () {
                  Navigator.pop(context);
                  onCameraPressed();
                },
              ),
              // Gallery option
              _buildAttachmentOption(
                icon: Icons.photo_library,
                label: 'คลังภาพ',
                onTap: () {
                  Navigator.pop(context);
                  onGalleryPressed();
                },
              ),
              // File option
              _buildAttachmentOption(
                icon: Icons.attach_file,
                label: 'ไฟล์',
                onTap: () {
                  Navigator.pop(context);
                  onFilePressed();
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF6EB715),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}