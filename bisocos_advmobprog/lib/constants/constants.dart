import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Get HOST from .env file or use fallback
String getHost() {
  try {
    return dotenv.env['HOST'] ?? 'https://dummyjson.com/products';
  } catch (e) {
    return 'https://dummyjson.com/products';
  }
}

// Shared colors, text styles, and application strings.
const Color primaryColor = Colors.blue;
const Color secondaryColor = Colors.orange;
const String appTitle = 'Products';
const String settingsTitle = 'Settings';
const TextStyle productTitleStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
);
const TextStyle productPriceStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: secondaryColor,
);
