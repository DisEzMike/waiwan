import 'package:flutter/material.dart';
import 'payment_button.dart';

class AmountSection extends StatelessWidget {
  final String totalAmount;
  final bool isProcessing;
  final VoidCallback onConfirmPayment;

  const AmountSection({
    super.key,
    required this.totalAmount,
    required this.isProcessing,
    required this.onConfirmPayment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ยอดชำระ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${totalAmount.replaceAll(' บาท', '')} บาท',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6EB715),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Confirm Payment Button
          PaymentButton(
            isProcessing: isProcessing,
            onPressed: onConfirmPayment,
          ),
        ],
      ),
    );
  }
}