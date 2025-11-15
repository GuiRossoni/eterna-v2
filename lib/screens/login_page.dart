import 'package:flutter/material.dart';
import '../widgets/shared.dart';
import '../components/organisms/login_card.dart';
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
          child: LoginCard(
            isDesktop: isDesktop,
            onSubmit: (email, pass) async {
              final navigator = Navigator.of(context);
              try {
                final firebaseReady =
                    await FirebaseAuthService.ensureInitialized();
                if (!mounted) return false;
                if (firebaseReady) {
                  final cred = await FirebaseAuthService().signIn(email, pass);
                  if (!mounted) return false;
                  if (cred.user != null) {
                    navigator.pushReplacementNamed('/home');
                    return true;
                  }
                }
              } catch (_) {}

              final ok = await _auth.login(email, pass);
              if (!mounted) return ok;
              if (ok) {
                navigator.pushReplacementNamed('/home');
              }
              return ok;
            },
            onForgot: () => Navigator.pushNamed(context, '/forgot-password'),
            onRegister: () => Navigator.pushNamed(context, '/register'),
          ),
        ),
      ),
    );
  }
}
