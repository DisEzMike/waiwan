import 'package:flutter/material.dart';
import '../../model/chat_message.dart';
import '../../widgets/payment/payment_success_dialog.dart';
import '../../widgets/payment/qr_code_section.dart';
import '../../widgets/payment/amount_section.dart';

class PaymentPage extends StatefulWidget {
  final PaymentDetails paymentDetails;
  final String elderlyPersonName;

  const PaymentPage({
    super.key,
    required this.paymentDetails,
    required this.elderlyPersonName,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isProcessing = false;

  void _confirmPayment() async {
    setState(() {
      _isProcessing = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });

      // Show success dialog
      _showPaymentSuccessDialog();
    }
  }

  void _showPaymentSuccessDialog() {
    PaymentSuccessDialog.show(
      context,
      widget.elderlyPersonName,
      () {
        Navigator.of(context).pop(); // Close dialog
        Navigator.of(context).pop(true); // Go back to chat with success result
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6EB715), // Green background like in the image
      appBar: AppBar(
        backgroundColor: const Color(0xFF6EB715),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'ชำระเงิน',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // QR Code Section
              QRCodeSection(
                timeText: 'เวลาคงเหลือ  ${_formatTime()}',
              ),
              
              // Amount Section
              AmountSection(
                totalAmount: widget.paymentDetails.totalAmount,
                isProcessing: _isProcessing,
                onConfirmPayment: _confirmPayment,
              ),
            ],
          ),
        ),
      ),
    );
  }

 
  String _formatTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }
}
