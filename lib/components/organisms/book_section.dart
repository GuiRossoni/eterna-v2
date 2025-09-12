import 'package:flutter/material.dart';
import '../../models/book_model.dart';
import '../molecules/book_card.dart';

class BookSection extends StatelessWidget {
  final String title;
  final List<BookModel> books;
  final void Function(BookModel, String heroTag) onSelect;
  final VoidCallback? onEndReached;

  const BookSection({
    super.key,
    required this.title,
    required this.books,
    required this.onSelect,
    this.onEndReached,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 210,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notif) {
              if (notif.metrics.pixels >= notif.metrics.maxScrollExtent - 100) {
                onEndReached?.call();
              }
              return false;
            },
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: books.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final book = books[index];
                final heroTag = '$title-${book.title}-$index';
                return BookCard(
                  sectionTitle: title,
                  heroTag: heroTag,
                  book: book,
                  onTap: () => onSelect(book, heroTag),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
