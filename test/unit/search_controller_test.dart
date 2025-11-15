import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run/models/book_model.dart';
import 'package:run/presentation/state/providers.dart';

import '../utils/fake_books_repository.dart';

void main() {
  group('SearchController', () {
    late FakeBooksRepository repository;
    late ProviderContainer container;

    setUp(() {
      repository = FakeBooksRepository();
      repository
        ..setSearchResponse('hobbit', 1, _buildBooks(startIndex: 0, count: 12))
        ..setSearchResponse('hobbit', 2, _buildBooks(startIndex: 12, count: 3));
      container = ProviderContainer(
        overrides: [booksRepositoryProvider.overrideWithValue(repository)],
      );
    });

    tearDown(() => container.dispose());

    test('usa cache ao repetir busca com o mesmo termo', () async {
      final controller = container.read(searchControllerProvider.notifier);

      await controller.search('hobbit');
      expect(repository.searchLog.length, 1);
      expect(container.read(searchControllerProvider).results.length, 12);

      await controller.search('hobbit');
      expect(repository.searchLog.length, 1, reason: 'resultado veio do cache');
    });

    test('loadMore concatena resultados e atualiza hasMore', () async {
      final controller = container.read(searchControllerProvider.notifier);

      await controller.search('hobbit');
      expect(container.read(searchControllerProvider).hasMore, isTrue);

      await controller.loadMore();
      final state = container.read(searchControllerProvider);
      expect(state.results.length, 15);
      expect(state.hasMore, isFalse);
      expect(repository.searchLog.length, 2);
    });

    test('clear zera resultados e estado', () async {
      final controller = container.read(searchControllerProvider.notifier);
      await controller.search('hobbit');
      controller.clear();

      final state = container.read(searchControllerProvider);
      expect(state.results, isEmpty);
      expect(state.query, isEmpty);
      expect(state.hasMore, isFalse);
    });
  });
}

List<BookModel> _buildBooks({required int startIndex, required int count}) {
  return List.generate(
    count,
    (i) => BookModel.network(
      title: 'Livro ${startIndex + i}',
      imageUrl: 'https://example.com/${startIndex + i}.jpg',
      synopsis: 'Sinopse ${startIndex + i}',
      authors: const ['Autor'],
    ),
  );
}
