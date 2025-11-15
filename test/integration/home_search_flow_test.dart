import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:run/components/organisms/book_section.dart';
import 'package:run/models/book_model.dart';
import 'package:run/models/listing_model.dart';
import 'package:run/presentation/state/providers.dart';
import 'package:run/screens/home_page.dart';
import 'package:run/services/listing_service.dart';

import '../utils/fake_books_repository.dart';

void main() {
  testWidgets('HomePage exibe resultados de busca e paginação incremental', (
    tester,
  ) async {
    final repository = FakeBooksRepository();
    repository
      ..setSearchResponse(
        'hobbit',
        1,
        _buildBooks(prefix: 'Busca Livro', startIndex: 0, count: 12),
      )
      ..setSearchResponse(
        'hobbit',
        2,
        _buildBooks(prefix: 'Busca Livro', startIndex: 12, count: 3),
      )
      ..setSubjectResponse(
        'fantasy',
        _buildBooks(prefix: 'Fantasia', startIndex: 0, count: 4),
      );

    final saleBooks = _buildBooks(
      prefix: 'Venda',
      startIndex: 0,
      count: 2,
      withPrice: true,
    );
    final swapBooks = _buildBooks(prefix: 'Troca', startIndex: 0, count: 2);
    final donationBooks = _buildBooks(
      prefix: 'Doacao',
      startIndex: 0,
      count: 1,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          booksRepositoryProvider.overrideWithValue(repository),
          listingServiceProvider.overrideWithValue(const _FakeListingService()),
          subjectBooksProvider.overrideWith((ref, subject) async {
            return repository.fetchBySubject(subject);
          }),
          saleListingsProvider.overrideWith(
            (ref) => Stream<List<BookModel>>.value(saleBooks),
          ),
          swapListingsProvider.overrideWith(
            (ref) => Stream<List<BookModel>>.value(swapBooks),
          ),
          donationListingsProvider.overrideWith(
            (ref) => Stream<List<BookModel>>.value(donationBooks),
          ),
        ],
        child: const MaterialApp(home: HomePage()),
      ),
    );

    await tester.pumpAndSettle();

    final searchField = find.widgetWithText(
      TextFormField,
      'Pesquisar livros...',
    );
    expect(searchField, findsOneWidget);

    await tester.enterText(searchField, 'Hobbit');
    await tester.tap(find.text('Buscar'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('Resultados para "Hobbit"'), findsOneWidget);
    expect(find.text('Busca Livro 0'), findsWidgets);

    final homeContext = tester.element(find.byType(HomePage));
    final container = ProviderScope.containerOf(homeContext);
    await container.read(searchControllerProvider.notifier).loadMore();
    await tester.pumpAndSettle();

    final searchSection = find.ancestor(
      of: find.text('Resultados para "Hobbit"'),
      matching: find.byType(BookSection),
    );
    final scrollable =
        find
            .descendant(of: searchSection, matching: find.byType(Scrollable))
            .first;
    await tester.scrollUntilVisible(
      find.text('Busca Livro 13'),
      4000,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();

    expect(find.text('Busca Livro 13'), findsOneWidget);
    expect(repository.searchLog.length, 2);
  });
}

List<BookModel> _buildBooks({
  required String prefix,
  required int startIndex,
  required int count,
  bool withPrice = false,
}) {
  return List.generate(
    count,
    (i) => BookModel.asset(
      title: '$prefix ${startIndex + i}',
      imageAsset: 'assets/logo.png',
      synopsis: 'Sinopse ${startIndex + i}',
      authors: const ['Autor'],
      price: withPrice ? 10 + i.toDouble() : null,
    ),
  );
}

class _FakeListingService implements ListingService {
  const _FakeListingService({String? currentUserId = 'tester'})
    : _currentUserId = currentUserId;

  final String? _currentUserId;

  @override
  String? get currentUserId => _currentUserId;

  @override
  Future<ListingModel> addListing({
    required String title,
    required List<String> authors,
    required String synopsis,
    String? imageUrl,
    required ListingType type,
    double? price,
    String? exchangeWanted,
  }) {
    throw UnimplementedError('addListing não é utilizado nos testes.');
  }

  @override
  Future<void> deleteListing(String id) async {}

  @override
  Stream<List<ListingModel>> watchByType(ListingType type) {
    return const Stream.empty();
  }

  @override
  Future<void> updateListing(
    String id, {
    String? title,
    List<String>? authors,
    String? synopsis,
    String? imageUrl,
    double? price,
    String? exchangeWanted,
    ListingType? type,
  }) async {}

  @override
  Future<int> migrateLegacyCreatedAt({int batchSize = 500}) async => 0;
}
