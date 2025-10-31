import 'package:flutter/material.dart';

class AppColors {
  static const Color greenPrimary = Color(0xFF4CAF50);
  static const Color greenAccent = Color(0xFF81C784);

  static const backgroundGradient = LinearGradient(
    colors: [Color(0xFFE8F5E9), Colors.white],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const greyBorder = OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey),
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );
}
