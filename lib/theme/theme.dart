import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    background: Colors.white,
    primary: Colors.grey.shade500,
    secondary: Colors.grey.shade100,
    inversePrimary: Colors.grey.shade900,
  ),
);

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    background: Colors.grey.shade900,
    primary: Colors.grey.shade500,
    secondary: Colors.grey.shade800,
    inversePrimary: Colors.grey.shade200,
  ),
);
