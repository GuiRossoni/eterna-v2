import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:run/components/atoms/app_button.dart';

void main() {
  testWidgets('AppButton exibe label e dispara onTap', (tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppButton(
              label: 'Confirmar',
              icon: Icons.check,
              onTap: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Confirmar'), findsOneWidget);
    expect(tapped, isFalse);

    await tester.tap(find.byType(AppButton));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
