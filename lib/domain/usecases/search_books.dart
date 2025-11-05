import '../../models/book_model.dart';
import '../repositories/books_repository.dart';

class SearchBooks {
  final BooksRepository repository;
  const SearchBooks(this.repository);

  Future<List<BookModel>> call(String query, {int limit = 12, int page = 1}) {
    return repository.search(query, limit: limit, page: page);
  }
}
