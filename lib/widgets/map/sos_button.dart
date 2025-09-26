import 'package:flutter/material.dart';

class SosButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const SosButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(right: 16, bottom: 8),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: onPressed ?? () {
            // Default SOS emergency action
            print('SOS Emergency!');
            // Show emergency dialog
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('ฉุกเฉิน'),
                content: const Text('กำลังส่งสัญญาณขอความช่วยเหลือ...'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('ตกลง'),
                  ),
                ],
              ),
            );
          },
          icon: const Icon(
            Icons.report_problem,
            color: Colors.white,
            size: 24,
          ),
          iconSize: 24,
          padding: const EdgeInsets.all(12),
        ),
      ),
    );
  }
}