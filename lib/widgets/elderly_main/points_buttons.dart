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
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: FilledButton.icon(
              onPressed: onCouponTap,
              icon: Image.asset(
                'assets/images/coupon.png',
                width: 24,
                height: 24,
              ),
              label: Text(
                'คะแนนของฉัน',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
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
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(204, 239, 178, 100),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                // stronger, more visible shadow per request
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  spreadRadius: 3,
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: FilledButton.icon(
              onPressed: onPointsTap,
              icon: Image.asset(
                'assets/images/p.png',
                width: 24,
                height: 24,
              ),
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
