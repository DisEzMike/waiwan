import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final String hintText;
  final VoidCallback? onTap;
  final Function(String)? onChanged;

  const CustomSearchBar({
    super.key,
    this.hintText = 'พบกล่อง',
    this.onTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SearchBar(
        hintText: hintText,
        leading: const Icon(Icons.search, size: 30),
        constraints: const BoxConstraints(
          maxHeight: 60,
          minHeight: 50,
        ),
        padding: const WidgetStatePropertyAll<EdgeInsets>(
          EdgeInsets.symmetric(horizontal: 24.0),
        ),
        hintStyle: WidgetStatePropertyAll<TextStyle>(
          TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        elevation: const WidgetStatePropertyAll<double>(1.0),
        onTap: onTap,
        onChanged: onChanged,
      ),
    );
  }
}