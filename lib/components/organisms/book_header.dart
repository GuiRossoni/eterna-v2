import 'package:flutter/material.dart';
import '../../components/atoms/book_cover.dart';

class BookHeader extends StatelessWidget {
  final String heroTag;
  final String? imageAsset;
  final String? imageUrl;
  final String synopsis;

  const BookHeader({
    super.key,
    required this.heroTag,
    this.imageAsset,
    this.imageUrl,
    required this.synopsis,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageUrl != null && imageUrl!.isNotEmpty)
          BookCover.network(
            imageUrl: imageUrl!,
            heroTag: heroTag,
            width: 150,
            height: 220,
            semanticLabel: 'Capa do ${synopsis.isNotEmpty ? 'livro' : 'item'}',
          )
        else if (imageAsset != null && imageAsset!.isNotEmpty)
          BookCover(
            imageAsset: imageAsset!,
            heroTag: heroTag,
            width: 150,
            height: 220,
            semanticLabel: 'Capa do ${synopsis.isNotEmpty ? 'livro' : 'item'}',
          )
        else
          Hero(
            tag: heroTag,
            child: Container(
              width: 150,
              height: 220,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[300],
              ),
              child: const Icon(Icons.book, size: 48),
            ),
          ),
        const SizedBox(width: 20),
        Expanded(
          child: Text(synopsis, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
