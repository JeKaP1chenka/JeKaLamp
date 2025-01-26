import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Colors.grey[700],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[850],
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.grey[850],
      ));

  static ThemeData lightTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: Colors.white,
  );

  static TextStyle sliderTextStyle =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
}
