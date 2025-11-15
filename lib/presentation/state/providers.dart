import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run/services/book_service.dart';
import 'package:run/data/repositories/books_repository_impl.dart';
import 'package:run/domain/repositories/books_repository.dart';
import 'package:run/domain/usecases/search_books.dart';
import 'package:run/domain/usecases/get_work_details.dart';
import 'package:run/domain/usecases/fetch_subject_books.dart';
import 'package:run/models/book_model.dart';
import 'package:run/models/listing_model.dart';
import 'package:run/models/review_model.dart';
import 'package:run/services/listing_service.dart';
import 'package:run/services/review_service.dart';
import 'cart.dart';

// Infra
final bookServiceProvider = Provider<BookService>((ref) => BookService());
final booksRepositoryProvider = Provider<BooksRepository>((ref) {
  final svc = ref.read(bookServiceProvider);
  return BooksRepositoryImpl(svc);
});

// Listings
final listingServiceProvider = Provider<ListingService>(
  (ref) => ListingService(),
);
final reviewServiceProvider = Provider<ReviewService>((ref) => ReviewService());

// Use cases
final searchBooksUseCaseProvider = Provider<SearchBooks>((ref) {
  final repo = ref.read(booksRepositoryProvider);
  return SearchBooks(repo);
});
final getWorkDetailsUseCaseProvider = Provider<GetWorkDetails>((ref) {
  final repo = ref.read(booksRepositoryProvider);
  return GetWorkDetails(repo);
});
final fetchSubjectBooksUseCaseProvider = Provider<FetchSubjectBooks>((ref) {
  final repo = ref.read(booksRepositoryProvider);
  return FetchSubjectBooks(repo);
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

final workReviewsProvider = StreamProvider.family
    .autoDispose<List<WorkReview>, String>((ref, workKey) {
      if (workKey.isEmpty) {
        return const Stream<List<WorkReview>>.empty();
      }
      final svc = ref.read(reviewServiceProvider);
      return svc.watchReviews(workKey);
    });

final workRatingProvider = Provider.autoDispose
    .family<AsyncValue<RatingSummary?>, String>((ref, workKey) {
      final reviewsAsync = ref.watch(workReviewsProvider(workKey));
      return reviewsAsync.when(
        data: (reviews) {
          final summary = RatingSummary.fromReviews(reviews);
          if (summary.count == 0 || summary.average == null) {
            return const AsyncValue<RatingSummary?>.data(null);
          }
          return AsyncValue<RatingSummary?>.data(summary);
        },
        loading: () => const AsyncValue<RatingSummary?>.loading(),
        error: (err, stack) => AsyncValue<RatingSummary?>.error(err, stack),
      );
    });

final subjectBooksProvider = FutureProvider.family<List<BookModel>, String>((
  ref,
  subject,
) async {
  final usecase = ref.read(fetchSubjectBooksUseCaseProvider);
  return usecase(subject, limit: 12);
});

// Stream providers mapping Firestore listings to BookModel for UI reuse
final saleListingsProvider = StreamProvider<List<BookModel>>((ref) {
  final svc = ref.read(listingServiceProvider);
  return svc
      .watchByType(ListingType.sale)
      .map(
        (list) =>
            list
                .map(
                  (l) => BookModel.network(
                    title: l.title,
                    imageUrl: l.imageUrl ?? '',
                    synopsis: l.synopsis,
                    authors: l.authors,
                    price: l.price,
                    listingId: l.id,
                    listingType: l.type.name,
                    exchangeWanted: l.exchangeWanted,
                    userId: l.userId,
                    userDisplayName: l.userDisplayName ?? l.userId,
                    createdAt: l.createdAt,
                  ),
                )
                .toList(),
      );
});

final swapListingsProvider = StreamProvider<List<BookModel>>((ref) {
  final svc = ref.read(listingServiceProvider);
  return svc
      .watchByType(ListingType.swap)
      .map(
        (list) =>
            list
                .map(
                  (l) => BookModel.network(
                    title: l.title,
                    imageUrl: l.imageUrl ?? '',
                    synopsis: l.synopsis,
                    authors: l.authors,
                    listingId: l.id,
                    listingType: l.type.name,
                    exchangeWanted: l.exchangeWanted,
                    userId: l.userId,
                    userDisplayName: l.userDisplayName ?? l.userId,
                    createdAt: l.createdAt,
                  ),
                )
                .toList(),
      );
});

final donationListingsProvider = StreamProvider<List<BookModel>>((ref) {
  final svc = ref.read(listingServiceProvider);
  return svc
      .watchByType(ListingType.donation)
      .map(
        (list) =>
            list
                .map(
                  (l) => BookModel.network(
                    title: l.title,
                    imageUrl: l.imageUrl ?? '',
                    synopsis: l.synopsis,
                    authors: l.authors,
                    listingId: l.id,
                    listingType: l.type.name,
                    exchangeWanted: l.exchangeWanted,
                    userId: l.userId,
                    userDisplayName: l.userDisplayName ?? l.userId,
                    createdAt: l.createdAt,
                  ),
                )
                .toList(),
      );
});

// Cart (re-export for central access)
final cartStateProvider = cartProvider;

// Local filtering & ordering for listings
enum SaleOrder { recent, priceAsc, priceDesc }

final listingsFilterQueryProvider = StateProvider<String>((ref) => '');
final saleOrderProvider = StateProvider<SaleOrder>((ref) => SaleOrder.recent);

final filteredOrderedSaleListingsProvider = Provider<List<BookModel>>((ref) {
  final base = ref
      .watch(saleListingsProvider)
      .maybeWhen(data: (list) => list, orElse: () => <BookModel>[]);
  final query = ref.watch(listingsFilterQueryProvider).trim().toLowerCase();
  final order = ref.watch(saleOrderProvider);
  var working = base;
  if (query.isNotEmpty) {
    working =
        working
            .where(
              (b) =>
                  b.title.toLowerCase().contains(query) ||
                  b.authors.any((a) => a.toLowerCase().contains(query)),
            )
            .toList();
  }
  switch (order) {
    case SaleOrder.recent:
      // Sort by most recent (nulls last)
      working.sort((a, b) {
        final ad = a.createdAt;
        final bd = b.createdAt;
        if (ad == null && bd == null) return 0;
        if (ad == null) return 1; // a after
        if (bd == null) return -1; // b after
        return bd.compareTo(ad); // descending
      });
      break;
    case SaleOrder.priceAsc:
      working.sort(
        (a, b) =>
            (a.price ?? double.infinity).compareTo(b.price ?? double.infinity),
      );
      break;
    case SaleOrder.priceDesc:
      working.sort((a, b) => (b.price ?? -1).compareTo(a.price ?? -1));
      break;
  }
  return working;
});

final filteredSwapListingsProvider = Provider<List<BookModel>>((ref) {
  final base = ref
      .watch(swapListingsProvider)
      .maybeWhen(data: (list) => list, orElse: () => <BookModel>[]);
  final query = ref.watch(listingsFilterQueryProvider).trim().toLowerCase();
  if (query.isEmpty) return base;
  return base
      .where(
        (b) =>
            b.title.toLowerCase().contains(query) ||
            b.authors.any((a) => a.toLowerCase().contains(query)) ||
            (b.exchangeWanted?.toLowerCase().contains(query) ?? false),
      )
      .toList();
});

final filteredDonationListingsProvider = Provider<List<BookModel>>((ref) {
  final base = ref
      .watch(donationListingsProvider)
      .maybeWhen(data: (list) => list, orElse: () => <BookModel>[]);
  final query = ref.watch(listingsFilterQueryProvider).trim().toLowerCase();
  if (query.isEmpty) return base;
  return base
      .where(
        (b) =>
            b.title.toLowerCase().contains(query) ||
            b.authors.any((a) => a.toLowerCase().contains(query)),
      )
      .toList();
});
