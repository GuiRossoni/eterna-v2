import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:run/screens/login_page.dart';
import 'package:run/screens/home_page.dart';
import 'package:run/services/auth_service.dart';
import 'package:run/components/organisms/login_form.dart';

void main() {
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
    await tester.pumpAndSettle();
    final invalidLoginFormFinder = find.byType(LoginForm);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'inexistente@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Senha'),
      'errada123',
    );
    final invalidLoginButton =
        find
            .descendant(
              of: invalidLoginFormFinder,
              matching: find.bySemanticsLabel('Entrar'),
            )
            .first;
    await tester.tap(invalidLoginButton);
    await tester.pump();

    var attempts = 0;
    while (attempts < 30 && find.text('Entrar').evaluate().isEmpty) {
      await tester.pump(const Duration(milliseconds: 200));
      attempts++;
    }

    expect(find.textContaining('Credenciais inválidas'), findsOneWidget);
  });
}
