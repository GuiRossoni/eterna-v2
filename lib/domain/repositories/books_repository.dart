import '../../models/book_model.dart';
import '../../services/book_service.dart';

/// Abstração do repositório de livros (Open Library)
abstract class BooksRepository {
  Future<List<BookModel>> search(String query, {int limit = 12, int page = 1});
  Future<WorkDetails> fetchWorkDetails(String workKey);
}
