import 'package:flutter/material.dart';
import '../../models/book_model.dart';
import '../atoms/book_cover.dart';

class BookCard extends StatefulWidget {
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
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final tag = '${widget.sectionTitle}-${widget.book.title}';
    return Semantics(
      button: true,
      label: 'Abrir detalhes do ${widget.book.title}',
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: widget.onTap,
          onHighlightChanged: (v) => setState(() => _pressed = v),
          child: BookCover(
            imageAsset: widget.book.imageAsset,
            heroTag: tag,
            semanticLabel: 'Capa do ${widget.book.title}',
          ),
        ),
      ),
    );
  }
}
