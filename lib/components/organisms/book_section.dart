import 'package:flutter/material.dart';
import '../../models/book_model.dart';
import '../molecules/book_card.dart';

class BookSection extends StatelessWidget {
  final String title;
  final List<BookModel> books;
  final void Function(BookModel) onSelect;

  const BookSection({
    super.key,
    required this.title,
    required this.books,
    required this.onSelect,
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
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final book = books[index];
              return BookCard(
                sectionTitle: title,
                book: book,
                onTap: () => onSelect(book),
              );
            },
          ),
        ),
      ],
    );
  }
}
