import 'package:flutter/material.dart';
import 'package:waiwan/utils/font_size_helper.dart';

Widget buildField(
  String label,
  TextEditingController controller, {
  int maxLines = 1,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: FontSizeHelper.createTextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        validator:
            (v) => (v == null || v.trim().isEmpty) ? 'กรุณาใส่ข้อมูล' : null,
      ),
      const SizedBox(height: 12),
    ],
  );
}
