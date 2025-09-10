import 'package:flutter/material.dart';
import '../../models/book_model.dart';
import '../atoms/book_cover.dart';

class BookCard extends StatelessWidget {
  final BookModel book;
  final VoidCallback onTap;
  final String sectionTitle;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    required this.sectionTitle,
  });

  @override
  Widget build(BuildContext context) {
    final tag = '${sectionTitle}-${book.title}';
    return Semantics(
      button: true,
      label: 'Abrir detalhes do ${book.title}',
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: BookCover(
          imageAsset: book.imageAsset,
          heroTag: tag,
          semanticLabel: 'Capa do ${book.title}',
        ),
      ),
    );
  }
}
