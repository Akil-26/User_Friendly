import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const kBgColor      = Color(0xFFFDF6EC);
const kPrimaryColor = Color(0xFFE8622A);
const kCardColor    = Colors.white;
const kDarkText     = Color(0xFF1A1A1A);
const kGrayText     = Color(0xFF888888);

final appTheme = ThemeData(
  scaffoldBackgroundColor: kBgColor,
  colorScheme: ColorScheme.fromSeed(
    seedColor: kPrimaryColor,
    surface: kBgColor,
  ),
  useMaterial3: true,
  textTheme: GoogleFonts.interTextTheme(),
  appBarTheme: const AppBarTheme(
    backgroundColor: kBgColor,
    elevation: 0,
    scrolledUnderElevation: 0,
    iconTheme: IconThemeData(color: kDarkText),
    titleTextStyle: TextStyle(
      color: kDarkText,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: kBgColor,
    selectedColor: kPrimaryColor,
    labelStyle: const TextStyle(fontSize: 13),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
);