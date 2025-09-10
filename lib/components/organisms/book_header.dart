import 'package:flutter/material.dart';
import '../../components/atoms/book_cover.dart';

class BookHeader extends StatelessWidget {
  final String heroTag;
  final String imageAsset;
  final String synopsis;

  const BookHeader({
    super.key,
    required this.heroTag,
    required this.imageAsset,
    required this.synopsis,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BookCover(
          imageAsset: imageAsset,
          heroTag: heroTag,
          width: 150,
          height: 220,
          semanticLabel: 'Capa do ${synopsis.isNotEmpty ? 'livro' : 'item'}',
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Text(synopsis, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
