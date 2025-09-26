import 'package:flutter/material.dart';

class NoReviewsState extends StatelessWidget {
  final String message;

  const NoReviewsState({
    super.key,
    this.message = 'ยังไม่มีรีวิว',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}