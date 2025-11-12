import 'package:flutter/material.dart';
import '../widgets/shared.dart';
import '../components/organisms/login_form.dart';
import '../services/auth_service.dart';
import '../services/firebase_auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: GlassPanel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isDesktop)
                Row(
                  children: [
                    Semantics(
                      image: true,
                      label: 'Logo do app',
                      child: Image.asset(
                        'assets/logo.png',
                        width: 260,
                        height: 260,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Login',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    Semantics(
                      image: true,
                      label: 'Logo do app',
                      child: Image.asset(
                        'assets/logo.png',
                        width: 350,
                        height: 175,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Login',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              LoginForm(
                onSubmit: (email, pass) async {
                  // Tenta Firebase com e-mail primeiro
                  try {
                    final firebaseReady =
                        await FirebaseAuthService.ensureInitialized();
                    if (firebaseReady) {
                      final cred = await FirebaseAuthService().signIn(
                        email,
                        pass,
                      );
                      if (cred.user != null) {
                        if (mounted) {
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                        return true;
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro de login Firebase: $e')),
                      );
                    }
                  }
                  // Fallback local
                  final ok = await _auth.login(email, pass);
                  if (ok && mounted) {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                  return ok;
                },
                onForgot:
                    () => Navigator.pushNamed(context, '/forgot-password'),
                onRegister: () => Navigator.pushNamed(context, '/register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
