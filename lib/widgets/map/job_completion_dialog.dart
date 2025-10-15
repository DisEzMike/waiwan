import 'package:flutter/material.dart';

class JobCompletionDialog extends StatelessWidget {
  final String elderlyPersonName;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const JobCompletionDialog({
    super.key,
    required this.elderlyPersonName,
    required this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text(
        'ยืนยันการจบงาน',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        'คุณแน่ใจหรือไม่ที่ต้องการจบงานให้ $elderlyPersonName?',
        style: const TextStyle(fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: onCancel ?? () {
            Navigator.of(context).pop(); // Close dialog
          },
          child: const Text(
            'ยกเลิก',
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6EB715),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'ยืนยัน',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  static void show(
    BuildContext context,
    String elderlyPersonName,
    VoidCallback onConfirm, {
    VoidCallback? onCancel,
  }) {
    showDialog(
      context: context,
      builder: (context) => JobCompletionDialog(
        elderlyPersonName: elderlyPersonName,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }
}