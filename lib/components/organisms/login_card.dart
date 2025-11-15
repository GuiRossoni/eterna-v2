import 'package:flutter/material.dart';
import '../molecules/auth_hero.dart';
import 'login_form.dart';

/// Glass panel content used on the login screen (hero + form).
class LoginCard extends StatelessWidget {
  final bool isDesktop;
  final Future<bool> Function(String email, String password) onSubmit;
  final VoidCallback onForgot;
  final VoidCallback onRegister;

  const LoginCard({
    super.key,
    required this.isDesktop,
    required this.onSubmit,
    required this.onForgot,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AuthHero(isDesktop: isDesktop, title: 'Login'),
        const SizedBox(height: 20),
        LoginForm(
          onSubmit: onSubmit,
          onForgot: onForgot,
          onRegister: onRegister,
        ),
      ],
    );
  }
}
