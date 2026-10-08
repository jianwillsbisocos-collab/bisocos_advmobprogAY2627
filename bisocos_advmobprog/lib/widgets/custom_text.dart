import 'package:flutter/material.dart';

// Reusable Text Widget
class CustomText extends StatelessWidget {
  const CustomText({required this.text, super.key, this.fontSize, this.fontWeight, this.color, this.maxLines, this.overflow});
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final int? maxLines;
  final TextOverflow? overflow;
  @override
  Widget build(BuildContext context) => Text(text, maxLines: maxLines, overflow: overflow, style: TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color));
}
