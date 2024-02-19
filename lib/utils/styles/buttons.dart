import 'package:flutter/material.dart';

// Base style for ElevatedButton
ButtonStyle elevatedButtonStyle(Color backgroundColor, Color foregroundColor) {
  return ElevatedButton.styleFrom(
    backgroundColor: backgroundColor,
    foregroundColor: foregroundColor,
  );
}

// Base style for OutlinedButton
ButtonStyle outlinedButtonStyle(Color color) {
  return OutlinedButton.styleFrom(
    foregroundColor: color,
    side: BorderSide(color: color, width: 2.0), // Border color and width
  );
}
