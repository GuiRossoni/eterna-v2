import '../../services/book_service.dart';
import '../repositories/books_repository.dart';

class GetWorkDetails {
  final BooksRepository repository;
  const GetWorkDetails(this.repository);

  Future<WorkDetails> call(String workKey) {
    return repository.fetchWorkDetails(workKey);
  }
}
