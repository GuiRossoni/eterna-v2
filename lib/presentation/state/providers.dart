import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run/services/book_service.dart';
import 'package:run/data/repositories/books_repository_impl.dart';
import 'package:run/domain/repositories/books_repository.dart';
import 'package:run/domain/usecases/search_books.dart';
import 'package:run/domain/usecases/get_work_details.dart';
import 'package:run/models/book_model.dart';
import 'cart.dart';

// Infra
final bookServiceProvider = Provider<BookService>((ref) => BookService());
final booksRepositoryProvider = Provider<BooksRepository>((ref) {
  final svc = ref.read(bookServiceProvider);
  return BooksRepositoryImpl(svc);
});

// Use cases
final searchBooksUseCaseProvider = Provider<SearchBooks>((ref) {
  final repo = ref.read(booksRepositoryProvider);
  return SearchBooks(repo);
});
final getWorkDetailsUseCaseProvider = Provider<GetWorkDetails>((ref) {
  final repo = ref.read(booksRepositoryProvider);
  return GetWorkDetails(repo);
});

// Search state
class SearchState {
  final List<BookModel> results;
  final String query;
  final bool loading;
  final bool loadingMore;
  final int page;
  final bool hasMore;
  final String? error;
  final Map<String, List<BookModel>> cache;

  const SearchState({
    this.results = const [],
    this.query = '',
    this.loading = false,
    this.loadingMore = false,
    this.page = 1,
    this.hasMore = false,
    this.error,
    this.cache = const {},
  });

  SearchState copyWith({
    List<BookModel>? results,
    String? query,
    bool? loading,
    bool? loadingMore,
    int? page,
    bool? hasMore,
    String? error,
    Map<String, List<BookModel>>? cache,
  }) => SearchState(
    results: results ?? this.results,
    query: query ?? this.query,
    loading: loading ?? this.loading,
    loadingMore: loadingMore ?? this.loadingMore,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    error: error,
    cache: cache ?? this.cache,
  );
}

class SearchController extends StateNotifier<SearchState> {
  final Ref ref;
  SearchController(this.ref) : super(const SearchState());

  static const int _pageSize = 12;

  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;
    state = state.copyWith(
      loading: true,
      loadingMore: false,
      query: query,
      page: 1,
      hasMore: false,
      results: const [],
      error: null,
    );

    try {
      if (state.cache.containsKey(query)) {
        final cached = state.cache[query]!;
        state = state.copyWith(
          results: cached,
          hasMore: cached.length >= _pageSize,
          loading: false,
        );
        return;
      }
      final usecase = ref.read(searchBooksUseCaseProvider);
      final items = await usecase(query, limit: _pageSize, page: 1);
      final newCache = Map<String, List<BookModel>>.from(state.cache);
      newCache[query] = items;
      state = state.copyWith(
        results: items,
        hasMore: items.length >= _pageSize,
        page: 1,
        loading: false,
        cache: newCache,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.loadingMore || !state.hasMore || state.query.isEmpty) return;
    state = state.copyWith(loadingMore: true);
    try {
      final usecase = ref.read(searchBooksUseCaseProvider);
      final nextPage = state.page + 1;
      final items = await usecase(
        state.query,
        limit: _pageSize,
        page: nextPage,
      );
      final all = List<BookModel>.from(state.results)..addAll(items);
      state = state.copyWith(
        results: all,
        page: nextPage,
        hasMore: items.length >= _pageSize,
        loadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(loadingMore: false, error: e.toString());
    }
  }

  void clear() {
    state = state.copyWith(
      results: const [],
      query: '',
      page: 1,
      hasMore: false,
      error: null,
    );
  }
}

final searchControllerProvider =
    StateNotifierProvider<SearchController, SearchState>(
      (ref) => SearchController(ref),
    );

// Work details provider (lazy)
final workDetailsProvider = FutureProvider.family
    .autoDispose<WorkDetails?, String>((ref, workKey) async {
      if (workKey.isEmpty) return null;
      final usecase = ref.read(getWorkDetailsUseCaseProvider);
      return usecase(workKey);
    });

// Cart (re-export for central access)
final cartStateProvider = cartProvider;
