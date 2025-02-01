import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class AppTheme {
  static const Color elementBackgroundColorDark =
      Color.fromARGB(255, 48, 48, 48);
  static const Color elementBackgroundColorLight =
      Color.fromARGB(255, 117, 117, 117);

  static const TextStyle elementTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static ButtonStyle buttonStyle = ButtonStyle(
    backgroundColor: WidgetStatePropertyAll(
      AppTheme.elementBackgroundColorLight,
    ),
    foregroundColor: WidgetStatePropertyAll(Colors.white),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Colors.grey[700],
      appBarTheme: AppBarTheme(
        backgroundColor: elementBackgroundColorDark,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: elementBackgroundColorDark,
      ));

  static ThemeData lightTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: Colors.white,
  );

  static TextStyle sliderTextStyle =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w500);

  static var elementButtonStyleData = ButtonStyleData(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(7),
      color: AppTheme.elementBackgroundColorLight,
    ),
    padding: EdgeInsets.symmetric(horizontal: 16),
    height: 40,
    width: 140,
  );

  static var elementDropdownStyleData = DropdownStyleData(
    offset: Offset(0, -3),
    maxHeight: 200,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(7),
      color: AppTheme.elementBackgroundColorDark,
    ),
    scrollbarTheme: ScrollbarThemeData(
      radius: const Radius.circular(40),
      thickness: WidgetStateProperty.all(6),
      thumbVisibility: WidgetStateProperty.all(true),
    ),
  );

  static var durationDropdownStyleData = DropdownStyleData(
    offset: Offset(0, -3),
    maxHeight: 200,
    width: 40,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(7),
      color: AppTheme.elementBackgroundColorDark,
    ),
    scrollbarTheme: ScrollbarThemeData(
      radius: const Radius.circular(40),
      thickness: WidgetStateProperty.all(6),
      thumbVisibility: WidgetStateProperty.all(true),
    ),
  );

  static InputDecoration dropdownMenuInputDecoration({required String text}) {
    return InputDecoration(
      floatingLabelAlignment: FloatingLabelAlignment.start,
      alignLabelWithHint: false,
      isDense: true,
      contentPadding: EdgeInsets.fromLTRB(8, 8, 4, 4),
      labelText: text,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
    );
  }
}
