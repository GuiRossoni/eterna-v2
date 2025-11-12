import 'package:run/domain/repositories/books_repository.dart';
import 'package:run/models/book_model.dart';

class FetchSubjectBooks {
  final BooksRepository _repository;
  const FetchSubjectBooks(this._repository);

  Future<List<BookModel>> call(
    String subject, {
    int limit = 12,
    int offset = 0,
  }) {
    return _repository.fetchBySubject(subject, limit: limit, offset: offset);
  }
}
