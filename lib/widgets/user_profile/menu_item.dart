import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/font_size_provider.dart';

class MenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final bool showDivider;

  const MenuItem({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final fontProvider = Provider.of<FontSizeProvider>(context);
    
    return Column(
      children: [
        ListTile(
          leading: Icon(
            icon, 
            color: Colors.black54,
            size: fontProvider.getScaledFontSize(24),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: fontProvider.getScaledFontSize(16),
              color: Colors.black87,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: Colors.black54,
            size: fontProvider.getScaledFontSize(24),
          ),
          onTap: onTap,
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}