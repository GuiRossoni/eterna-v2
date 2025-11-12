import 'package:run/services/book_service.dart';
import 'package:run/models/book_model.dart';
import 'package:run/domain/repositories/books_repository.dart';

class BooksRepositoryImpl implements BooksRepository {
  final BookService _service;
  BooksRepositoryImpl(this._service);

  @override
  Future<List<BookModel>> search(
    String query, {
    int limit = 12,
    int page = 1,
  }) async {
    final remotes = await _service.search(query, limit: limit, page: page);
    return remotes
        .map(
          (r) => BookModel.network(
            title: r.title,
            imageUrl: r.imageUrl,
            synopsis: r.synopsis,
            authors: r.authors,
            workKey: r.workKey,
            year: r.firstPublishYear,
          ),
        )
        .toList();
  }

  @override
  Future<WorkDetails> fetchWorkDetails(String workKey) {
    return _service.fetchWorkDetails(workKey);
  }

  @override
  Future<List<BookModel>> fetchBySubject(
    String subject, {
    int limit = 12,
    int offset = 0,
  }) async {
    final remotes = await _service.fetchBySubject(
      subject,
      limit: limit,
      offset: offset,
    );
    return remotes
        .map(
          (r) => BookModel.network(
            title: r.title,
            imageUrl: r.imageUrl,
            synopsis: r.synopsis,
            authors: r.authors,
            workKey: r.workKey,
            year: r.firstPublishYear,
          ),
        )
        .toList();
  }
}
