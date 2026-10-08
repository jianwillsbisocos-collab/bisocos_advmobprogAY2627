import 'package:flutter/material.dart';

class AuthFormField extends StatelessWidget {
  const AuthFormField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
    this.maxLength,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffixIcon;
  final int? maxLength;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    textInputAction: textInputAction,
    obscureText: obscureText,
    maxLength: maxLength,
    validator: validator,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      border: const OutlineInputBorder(),
      counterText: '',
    ),
  );
}
