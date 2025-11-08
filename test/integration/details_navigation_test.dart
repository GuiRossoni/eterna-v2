import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:run/models/book_model.dart';
import 'package:run/components/organisms/book_section.dart';
import 'package:run/screens/book_details_page.dart';

void main() {
  testWidgets('Navega do carrossel (asset) para os detalhes e exibe conteúdo', (
    tester,
  ) async {
    final books = [
      const BookModel.asset(
        title: 'Livro 1',
        imageAsset: 'assets/imagens/Livro1.webp',
        synopsis: 'Sinopse do livro 1.',
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          routes: {'/book-details': (_) => const BookDetailsPage()},
          home: Scaffold(
            appBar: AppBar(title: const Text('Teste')),
            body: BookSection(
              title: 'Livros em Alta',
              books: books,
              onSelect: (b, hero) {
                Navigator.pushNamed(
                  tester.element(find.byType(BookSection)),
                  '/book-details',
                  arguments: {
                    'title': b.title,
                    'sinopse': b.synopsis,
                    'heroTag': hero,
                    'imageAsset': b.imageAsset,
                  },
                );
              },
            ),
          ),
        ),
      ),
    );

    // Tocar no primeiro card (evita ambiguidade escolhendo o widget dentro do carrossel)
    final listItem =
        find
            .descendant(
              of: find.byType(BookSection),
              matching: find.text('Livro 1'),
            )
            .first;
    await tester.tap(listItem);
    await tester.pumpAndSettle();

    // Deve mostrar a AppBar com o título e seção de comentários
    expect(find.text('Livro 1'), findsWidgets);
    expect(find.text('Comentários:'), findsOneWidget);
  });
}
