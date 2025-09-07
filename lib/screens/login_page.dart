import 'package:flutter/material.dart';
import '../widgets/shared.dart';
import '../components/organisms/login_form.dart';
import '../services/auth_service.dart';

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
                        width: 60,
                        height: 60,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Login",
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
                        width: 80,
                        height: 80,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Login",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              LoginForm(
                onSubmit: (user, pass) async {
                  final ok = await _auth.login(user, pass);
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
