import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Definición de paleta de colores para un tema de Zentra.
class ZentraThemePalette {
  final String id;
  final String name;
  final String subtitle;
  final Color background;
  final Color primary;
  final Color secondary;
  final Color textDark;
  final Color success;
  final Color alert;

  const ZentraThemePalette({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.background,
    required this.primary,
    required this.secondary,
    required this.textDark,
    required this.success,
    required this.alert,
  });

  /// Genera el ThemeData de Flutter manteniendo la tipografía Poppins intacta.
  ThemeData toThemeData() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: Colors.white,
        error: alert,
        onPrimary: textDark,
        onSecondary: Colors.white,
        onSurface: textDark,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textDark,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textDark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: secondary, width: 2),
        ),
        labelStyle: TextStyle(color: textDark),
        prefixIconColor: textDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
      ),
    );
  }
}

/// Registro central de los 4 temas personalizables de Zentra.
class AppTheme {
  // 1. TEMA 1: Nude & Blush (Tema Original de Tatiana / Artesanal)
  static const ZentraThemePalette nudeBlush = ZentraThemePalette(
    id: 'nude_blush',
    name: 'Nude & Blush',
    subtitle: 'Artesanal, femenino y delicado (Caso Tatiana)',
    background: Color(0xFFF5EFE6), // Nude arena claro
    primary: Color(0xFFE8C4C4),    // Blush rosado
    secondary: Color(0xFFD4A5A5),  // Rosado fuerte para botones
    textDark: Color(0xFF5C4A3E),   // Café espresso cálido
    success: Color(0xFFA3B18A),    // Verde salvia suave
    alert: Color(0xFFE07A5F),      // Naranja terracota
  );

  // 2. TEMA 2: Esmeralda & Menta (Comercio & Retail Moderno)
  static const ZentraThemePalette esmeraldaMenta = ZentraThemePalette(
    id: 'esmeralda_menta',
    name: 'Esmeralda & Menta',
    subtitle: 'Comercial, fresco y de confianza (Don Pedro / Tiendas)',
    background: Color(0xFFF0F7F4), // Menta hielo muy suave
    primary: Color(0xFFA7D7C5),    // Menta pastel
    secondary: Color(0xFF2C7A7B),  // Verde esmeralda profundo
    textDark: Color(0xFF13322B),   // Verde petróleo casi negro
    success: Color(0xFF38A169),    // Verde esmeralda vibrante
    alert: Color(0xFFE53E3E),      // Rojo coral
  );

  // 3. TEMA 3: Lavanda & Ciruela (Elegancia & Bienestar)
  static const ZentraThemePalette lavandaCiruela = ZentraThemePalette(
    id: 'lavanda_ciruela',
    name: 'Lavanda & Ciruela',
    subtitle: 'Elegante, relajante y premium (Salones, Moda y Spas)',
    background: Color(0xFFF8F5FA), // Lila nube muy claro
    primary: Color(0xFFD6C7E2),    // Lavanda pastel
    secondary: Color(0xFF7B5294),  // Ciruela púrpura
    textDark: Color(0xFF2E2036),   // Berenjena oscuro
    success: Color(0xFF48BB78),    // Verde jade
    alert: Color(0xFFED8936),      // Naranja ámbar
  );

  // 4. TEMA 4: Océano & Medianoche (Sobrio & Ejecutivo)
  static const ZentraThemePalette oceanoNavy = ZentraThemePalette(
    id: 'oceano_navy',
    name: 'Océano & Medianoche',
    subtitle: 'Ejecutivo, tecnológico y alto contraste',
    background: Color(0xFFF1F5F9), // Slate 100 glaciar
    primary: Color(0xFFBAE6FD),    // Sky azul suave
    secondary: Color(0xFF1D4ED8),  // Azul zafiro / Blue 700
    textDark: Color(0xFF0F172A),   // Azul medianoche / Slate 900
    success: Color(0xFF059669),    // Verde esmeralda
    alert: Color(0xFFEA580C),      // Naranja fuego
  );

  /// Lista con los 4 temas seleccionables por el usuario
  static const List<ZentraThemePalette> allThemes = [
    nudeBlush,
    esmeraldaMenta,
    lavandaCiruela,
    oceanoNavy,
  ];

  /// Obtiene la paleta activa a partir de su ID
  static ZentraThemePalette getThemeById(String id) {
    return allThemes.firstWhere(
      (t) => t.id == id,
      orElse: () => nudeBlush,
    );
  }

  /// Retorna el ThemeData por defecto (Nude & Blush)
  static ThemeData get lightTheme => nudeBlush.toThemeData();
}
