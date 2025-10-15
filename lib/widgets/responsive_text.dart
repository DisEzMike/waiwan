import 'package:flutter/material.dart';
import '../providers/font_size_provider.dart';
import '../utils/font_size_helper.dart';

/// A responsive text widget that automatically updates when font size changes
class ResponsiveText extends StatefulWidget {
  final String text;
  final double fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final double? height;
  final TextDecoration? decoration;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    super.key,
    required this.fontSize,
    this.fontWeight,
    this.color,
    this.height,
    this.decoration,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  State<ResponsiveText> createState() => _ResponsiveTextState();
}

class _ResponsiveTextState extends State<ResponsiveText> {
  @override
  void initState() {
    super.initState();
    // Listen to font size changes
    FontSizeProvider.instance.addListener(_onFontSizeChanged);
  }

  @override
  void dispose() {
    FontSizeProvider.instance.removeListener(_onFontSizeChanged);
    super.dispose();
  }

  void _onFontSizeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text,
      style: FontSizeHelper.createTextStyle(
        fontSize: widget.fontSize,
        fontWeight: widget.fontWeight,
        color: widget.color,
        height: widget.height,
        decoration: widget.decoration,
      ),
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}