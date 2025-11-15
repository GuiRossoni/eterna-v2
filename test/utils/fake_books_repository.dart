import 'package:run/domain/repositories/books_repository.dart';
import 'package:run/models/book_model.dart';
import 'package:run/services/book_service.dart';

/// Simple in-memory repository used to stub Open Library results in tests.
class FakeBooksRepository implements BooksRepository {
  FakeBooksRepository({
    Map<String, Map<int, List<BookModel>>>? searchResponses,
    Map<String, List<BookModel>>? subjectResponses,
  }) : _searchResponses = searchResponses ?? {},
       _subjectResponses = subjectResponses ?? {};

  final Map<String, Map<int, List<BookModel>>> _searchResponses;
  final Map<String, List<BookModel>> _subjectResponses;
  final List<SearchInvocation> searchLog = [];

  void setSearchResponse(String query, int page, List<BookModel> books) {
    final normalized = query.trim().toLowerCase();
    final pages = _searchResponses.putIfAbsent(normalized, () => {});
    pages[page] = List.unmodifiable(books);
  }

  void setSubjectResponse(String subject, List<BookModel> books) {
    _subjectResponses[subject.toLowerCase()] = List.unmodifiable(books);
  }

  @override
  Future<List<BookModel>> search(
    String query, {
    int limit = 12,
    int page = 1,
  }) async {
    final normalized = query.trim().toLowerCase();
    searchLog.add(SearchInvocation(normalized, page, limit));
    final pages = _searchResponses[normalized];
    if (pages == null) return const [];
    return List<BookModel>.from(pages[page] ?? const []);
  }

  @override
  Future<List<BookModel>> fetchBySubject(
    String subject, {
    int limit = 12,
    int offset = 0,
  }) async {
    final normalized = subject.trim().toLowerCase();
    return List<BookModel>.from(_subjectResponses[normalized] ?? const []);
  }

  @override
  Future<WorkDetails> fetchWorkDetails(String workKey) async {
    return const WorkDetails();
  }
}

class SearchInvocation {
  final String query;
  final int page;
  final int limit;
  const SearchInvocation(this.query, this.page, this.limit);
}
