import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:run/components/organisms/book_section.dart';
import 'package:run/models/book_model.dart';

void main() {
  testWidgets('BookSection renderiza itens e chama onEndReached ao fim', (
    tester,
  ) async {
    final books = List.generate(
      8,
      (i) => BookModel.asset(
        title: 'Livro $i',
        imageAsset: 'assets/imagens/Livro1.webp',
        synopsis: 'Sinopse $i',
      ),
    );

    bool endReached = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BookSection(
            title: 'Seção',
            books: books,
            onSelect: (_, __) {},
            onEndReached: () => endReached = true,
          ),
        ),
      ),
    );

    expect(find.text('Seção'), findsOneWidget);

    // Rolar até o fim do carrossel
    final listFinder = find.byType(ListView);
    await tester.drag(listFinder, const Offset(-2000, 0));
    await tester.pumpAndSettle();

    expect(endReached, isTrue);
  });
}
