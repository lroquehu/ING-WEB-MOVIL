import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colores extraídos de tu CSS
  static const Color primary = Color(0xFF910202); // --primary-color
  static const Color primaryDark = Color(0xFF700101); // --primary-dark
  static const Color accent = Color(0xFFFFD700); // --accent-color (Dorado)
  static const Color textDark = Color(0xFF333333); // --text-dark
  static const Color textLight = Color(0xFF666666); // --text-light
  static const Color background = Color(0xFFF8F9FA); // --bg-light

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: primaryDark,
        // CORRECCIÓN 1: 'background' ahora es 'surface' en las nuevas versiones de Flutter
        surface: background,
      ),
      scaffoldBackgroundColor: background,

      // CORRECCIÓN 2: Segoe UI no está en Google Fonts (es de Microsoft).
      // Usamos 'Roboto' o 'OpenSans' que son muy similares y gratuitas.
      textTheme: GoogleFonts.robotoTextTheme(),

      // Estilo de Inputs (Cajas de texto)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE1E1E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE1E1E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        labelStyle: const TextStyle(color: textLight),
      ),

      // Estilo de Botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          elevation: 4,
        ),
      ),
    );
  }
}
