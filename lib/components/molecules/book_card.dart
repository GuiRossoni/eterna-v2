import 'package:flutter/material.dart';
import '../../models/book_model.dart';
import '../atoms/book_cover.dart';

class BookCard extends StatefulWidget {
  final BookModel book;
  final VoidCallback onTap;
  final String sectionTitle;
  final String heroTag;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    required this.sectionTitle,
    required this.heroTag,
  });

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Abrir detalhes do ${widget.book.title}',
      child: Focus(
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          child: Builder(
            builder: (context) {
              final hasFocus = Focus.of(context).hasPrimaryFocus;
              final hasNetwork = widget.book.isNetwork;
              final hasAsset =
                  widget.book.imageAsset != null &&
                  widget.book.imageAsset!.isNotEmpty;
              final double coverWidth = 110;
              final double coverHeight =
                  120; // Ajustado para evitar overflow no tile (h≈164)
              final Widget cover =
                  hasNetwork
                      ? BookCover.network(
                        imageUrl: widget.book.imageUrl!,
                        heroTag: widget.heroTag,
                        semanticLabel: 'Capa do ${widget.book.title}',
                        width: coverWidth,
                        height: coverHeight,
                      )
                      : hasAsset
                      ? BookCover(
                        imageAsset: widget.book.imageAsset!,
                        heroTag: widget.heroTag,
                        semanticLabel: 'Capa do ${widget.book.title}',
                        width: coverWidth,
                        height: coverHeight,
                      )
                      : Hero(
                        tag: widget.heroTag,
                        child: Container(
                          width: coverWidth,
                          height: coverHeight,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[300],
                          ),
                          child: const Icon(Icons.book, size: 36),
                        ),
                      );
              return InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: widget.onTap,
                onHighlightChanged: (v) => setState(() => _pressed = v),
                child: Container(
                  decoration:
                      hasFocus
                          ? BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          )
                          : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      cover,
                      const SizedBox(height: 6),
                      SizedBox(
                        width: coverWidth,
                        child: Text(
                          widget.book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
