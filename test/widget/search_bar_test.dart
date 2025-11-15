import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:run/components/molecules/search_bar.dart';

void main() {
  testWidgets('SearchBar valida entradas e dispara onSearch', (tester) async {
    String? lastQuery;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SearchBarMolecule(onSearch: (value) => lastQuery = value),
        ),
      ),
    );

    await tester.tap(find.text('Buscar'));
    await tester.pump();
    expect(find.text('Digite algo para pesquisar'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Pesquisar livros...'),
      'ab',
    );
    await tester.tap(find.text('Buscar'));
    await tester.pump();
    expect(find.text('Digite pelo menos 3 caracteres'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Pesquisar livros...'),
      'Hobbit',
    );
    await tester.tap(find.text('Buscar'));
    await tester.pump(const Duration(milliseconds: 350));

    expect(lastQuery, 'Hobbit');
  });
}
