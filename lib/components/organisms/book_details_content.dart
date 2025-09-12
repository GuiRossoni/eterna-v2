import 'package:flutter/material.dart';
import '../molecules/rating_bar.dart';
import '../molecules/comment_item.dart';
import 'book_header.dart';

class BookDetailsContent extends StatefulWidget {
  final String heroTag;
  final String? imageAsset;
  final String? imageUrl;
  final String title;
  final String synopsis;

  const BookDetailsContent({
    super.key,
    required this.heroTag,
    this.imageAsset,
    this.imageUrl,
    required this.title,
    required this.synopsis,
  });

  @override
  State<BookDetailsContent> createState() => _BookDetailsContentState();
}

class _BookDetailsContentState extends State<BookDetailsContent> {
  int rating = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BookHeader(
          heroTag: widget.heroTag,
          imageAsset: widget.imageAsset,
          imageUrl: widget.imageUrl,
          synopsis: widget.synopsis,
        ),
        const SizedBox(height: 20),
        RatingBar(rating: rating, onChange: (r) => setState(() => rating = r)),
        const SizedBox(height: 20),
        Text('Comentários:', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 10),
        Expanded(
          child: ListView(
            children: const [
              CommentItem(user: 'Maria', stars: 5, text: 'Amei esse livro!'),
              CommentItem(
                user: 'João',
                stars: 4,
                text: 'Muito bom, mas poderia ser menor.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
