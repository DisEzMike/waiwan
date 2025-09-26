import 'package:flutter/material.dart';

class PointsButtons extends StatelessWidget {
  final VoidCallback? onCouponTap;
  final VoidCallback? onPointsTap;
  final String pointsText;

  const PointsButtons({
    super.key,
    this.onCouponTap,
    this.onPointsTap,
    this.pointsText = '1000 คะแนน',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: onCouponTap,
            icon: Image.asset('assets/images/coupon.png', width: 24, height: 24),
            label: const Text(
              'คะแนนของฉัน',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFFFFF), // White (0%)
                  Color(0xFF6EB715), // Green (100% at 95%)
                ],
                stops: [0.0, 0.95],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: FilledButton.icon(
              onPressed: onPointsTap,
              icon: Image.asset('assets/images/p.png', width: 24, height: 24),
              label: Text(
                pointsText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.black,
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
            ),
          ),
        ),
      ],
    );
  }
}