import 'package:flutter/material.dart';

class AppColors {
  static const lightBlue = Color(0xFFE3F2FD);
  static const primaryBlue = Color(0xFF90CAF9);
  static const white = Colors.white;

  static final playerGradient = LinearGradient(
    colors: [lightBlue, white],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
