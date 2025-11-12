import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

import 'widgets/shared.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/forgot_password_page.dart';
import 'screens/home_page.dart';
import 'screens/profile_page.dart';
import 'screens/cart_page.dart';
import 'screens/add_listing_page.dart';
import 'screens/edit_listing_page.dart';

import 'screens/book_details_page.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa Firebase explicitamente; se falhar, continua sem travar.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Ativa persistência (já padrão em mobile; explicitado para clareza) e configura cache se quiser.
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
  } catch (_) {
    // Pode logar ou ignorar; fallback para AuthService local.
  }
  await AuthService().init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biblioteca Virtual',
      debugShowCheckedModeBanner: false,
      // Tema atualizado para paleta pastel
      theme: buildEternaTheme(),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/home': (context) => const HomePage(),
        '/book-details': (context) => const BookDetailsPage(),
        '/profile': (context) => const ProfilePage(),
        '/cart': (context) => const CartPage(),
        '/add-listing': (context) => const AddListingPage(),
        '/edit-listing': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return EditListingPage(args: (args is Map) ? args : {});
        },
      },
    );
  }
}
