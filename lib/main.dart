import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/shared.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/forgot_password_page.dart';
import 'screens/home_page.dart';

import 'screens/book_details_page.dart';
import 'widgets/atomic_demo.dart';
import 'screens/api_demo_page.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biblioteca Virtual',
      debugShowCheckedModeBanner: false,
      // Localizations podem ser adicionadas posteriormente quando as dependências estiverem disponíveis.
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          surface: AppColors.fundoClaro,
          primary: AppColors.acentoPrincipal,
          secondary: AppColors.acentoSecundario,
          error: AppColors.alerta,
        ),
        textTheme: TextTheme(
          headlineLarge: GoogleFonts.dmSerifDisplay(
            color: AppColors.textoPrincipal,
            fontSize: 32,
          ),
          headlineSmall: GoogleFonts.dmSerifDisplay(
            color: AppColors.textoPrincipal,
            fontSize: 22,
          ),
          bodyMedium: GoogleFonts.inter(
            color: AppColors.textoPrincipal,
            fontSize: 16,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: const Color.fromRGBO(255, 255, 255, 0.6),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.acentoPrincipal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/home': (context) => const HomePage(),
        '/book-details': (context) => const BookDetailsPage(),
        '/atomic-demo': (context) => const AtomicDemoPage(),
        '/api-demo': (context) => const ApiDemoPage(),
      },
    );
  }
}
