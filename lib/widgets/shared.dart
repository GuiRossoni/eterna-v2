import 'package:flutter/material.dart';

// =================== PALETA DE CORES ===================
class AppColors {
  static const Color fundoClaro = Color(0xFFF9F6F2);
  static const Color fundoEscuro = Color(0xFF1C2B2D);
  static const Color acentoPrincipal = Color(0xFFD4A373);
  static const Color acentoSecundario = Color(0xFFA3B18A);
  static const Color textoPrincipal = Color(0xFF2F2F2F);
  static const Color textoSobreEscuro = Color(0xFFF0F0F0);
  static const Color alerta = Color(0xFFE76F51);
  static const Color links = Color(0xFF4A6D7C);
}

// =================== WIDGET PAINEL VIDRO ===================
class GlassPanel extends StatelessWidget {
  final Widget child;
  const GlassPanel({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.4)),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
