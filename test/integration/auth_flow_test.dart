import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:run/screens/login_page.dart';
import 'package:run/screens/register_page.dart';
import 'package:run/screens/forgot_password_page.dart';
import 'package:run/screens/home_page.dart';
import 'package:run/services/auth_service.dart';

void main() {
  testWidgets('Fluxo de cadastro -> volta ao login -> login com sucesso', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          routes: {
            '/': (_) => const LoginPage(),
            '/register': (_) => const RegisterPage(),
            '/forgot-password': (_) => const ForgotPasswordPage(),
            '/home': (_) => const HomePage(),
          },
          initialRoute: '/',
        ),
      ),
    );

    expect(find.text('Login'), findsOneWidget);
    await tester.ensureVisible(find.text('Cadastrar').first);
    await tester.tap(find.text('Cadastrar').first);
    await tester.pumpAndSettle();

    expect(find.text('Cadastro'), findsWidgets);

    // Novo fluxo simplificado: Nome de Usuário, Email, Senha, Confirmar Senha
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome de Usuário'),
      'user_teste',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'teste@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Senha'),
      'segredo',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Confirmar Senha'),
      'segredo',
    );

    await tester.ensureVisible(find.text('Cadastrar').first);
    await tester.tap(find.text('Cadastrar').first);
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'teste@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Senha'),
      'segredo',
    );
    await tester.ensureVisible(find.text('Entrar').first);
    await tester.tap(find.text('Entrar').first);

    await tester.pumpAndSettle();

    expect(find.text('Biblioteca Virtual'), findsOneWidget);
    expect(find.text('Livros em Alta'), findsOneWidget);
  });

  testWidgets('Fluxo de login inválido exibe Snackbar', (tester) async {
    final users = await AuthService().listUsers();
    expect(users.any((u) => u['username'] == 'inexistente'), isFalse);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          routes: {
            '/': (_) => const LoginPage(),
            '/home': (_) => const HomePage(),
          },
          initialRoute: '/',
        ),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'inexistente@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Senha'),
      'errada123',
    );
    await tester.tap(find.text('Entrar').first);
    await tester.pump();

    expect(find.text('Credenciais inválidas.'), findsOneWidget);
  });
}
