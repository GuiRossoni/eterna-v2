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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final theme = Theme.of(context);
              final hasFocus = Focus.of(context).hasPrimaryFocus;
              final hasNetwork = widget.book.isNetwork;
              final hasAsset =
                  widget.book.imageAsset != null &&
                  widget.book.imageAsset!.isNotEmpty;

              const double coverWidth = 110;
              const double spacing = 6;
              const double desiredCoverHeight = 120;
              final textStyle = theme.textTheme.bodySmall;
              final double fontSize = textStyle?.fontSize ?? 12;
              final double lineHeightFactor = textStyle?.height ?? 1.2;
              final double textBlockHeight = fontSize * lineHeightFactor * 2;

              double coverHeight = desiredCoverHeight;
              final bool hasBoundedHeight = constraints.maxHeight.isFinite;
              if (hasBoundedHeight) {
                final double available =
                    constraints.maxHeight - spacing - textBlockHeight;
                if (available.isFinite) {
                  coverHeight = available.clamp(0.0, desiredCoverHeight);
                }
              }
              if (!hasBoundedHeight && coverHeight <= 0) {
                coverHeight = desiredCoverHeight;
              }

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
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                          )
                          : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      cover,
                      const SizedBox(height: spacing),
                      SizedBox(
                        width: coverWidth,
                        height: textBlockHeight,
                        child: Text(
                          widget.book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textStyle,
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
