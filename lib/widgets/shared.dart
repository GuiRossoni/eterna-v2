import 'package:flutter/material.dart';

// =================== NOVA PALETA PASTEL ===================
const Color pastelBackground = Color.fromARGB(255, 228, 219, 212);
const Color pastelCard = Color(0xFFF7F2EE);
const Color pastelAccent = Color(0xFFEAA1A1);
const Color pastelSecondary = Color(0xFFCFC0B6);
const Color pastelGreen = Color(0xFFB9E4C9);

// Mantemos a classe mas com nomes compatíveis se necessário em algum legado
class AppColors {
  static const Color fundoClaro = Color.fromARGB(255, 240, 231, 224);
  static const Color acentoPrincipal = pastelAccent;
  static const Color acentoSecundario = pastelGreen;
  static const Color textoPrincipal = Color(0xFF2F2F2F);
  static const Color alerta = Color(0xFFE76F51); // pode ser ajustado depois
}

ThemeData buildEternaTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: pastelBackground,
    fontFamily: 'Arial',
    primaryColor: pastelAccent,
    colorScheme: ColorScheme.fromSeed(seedColor: pastelAccent).copyWith(
      primary: pastelAccent,
      surface: pastelCard,
      secondary: pastelGreen,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: pastelCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.grey[800]),
      titleTextStyle: const TextStyle(
        fontFamily: 'Arial',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontFamily: 'Arial',
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      bodyMedium: TextStyle(fontFamily: 'Arial', color: Colors.black87),
    ),
    cardTheme: CardThemeData(
      color: pastelCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 2,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: pastelAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        textStyle: const TextStyle(
          fontFamily: 'Arial',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

// Helper para card arredondado
Widget roundedCard({required Widget child, EdgeInsets? padding}) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    child: Padding(padding: padding ?? const EdgeInsets.all(12), child: child),
  );
}

/// Painel glassmorphism adaptado à nova paleta
class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        decoration: BoxDecoration(
          // Aumenta o contraste em relação ao background
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: pastelSecondary.withOpacity(0.5), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
