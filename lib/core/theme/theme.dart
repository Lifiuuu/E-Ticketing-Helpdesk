import 'package:flutter/material.dart';

class AppThemes {
  // Warna utama aplikasi (Sesuaikan dengan identitas E-Ticketing-mu)
  static const primaryColor = Colors.blueAccent;

  // 1. LIGHT THEME CONFIGURATION 
  static final light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: primaryColor,
    
    // Gaya AppBar agar konsisten di semua screen [cite: 112]
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    // Gaya Input Field (Login, Register, Create Ticket)
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey[100],
    ),

    // Gaya Tombol Utama (ElevatedButton)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  // 2. DARK THEME CONFIGURATION 
  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: primaryColor,
    
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}