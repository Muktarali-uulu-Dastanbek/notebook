import 'package:flutter/material.dart';
import 'package:notebook/theme/themes/text_theme.dart';

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Poppins',
  brightness: Brightness.light,
  primaryColor: Colors.blue,
  scaffoldBackgroundColor: Colors.white,
  textTheme: TTextTheme.lightTextTheme,
  colorScheme: ColorScheme.light(
    background: Colors.white,
    primaryContainer: Colors.black,
    primary: Colors.grey.shade100,
    secondary: Colors.grey.shade400,
  ),
);

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Poppins',
  brightness: Brightness.dark,
  primaryColor: Colors.blue,
  scaffoldBackgroundColor: Colors.black,
  textTheme: TTextTheme.darkTextTheme,
  colorScheme: ColorScheme.dark(
    background: Colors.black,
    primaryContainer: Colors.white,
    primary: Colors.grey.shade900,
    secondary: Colors.grey.shade600,
  ),
);
