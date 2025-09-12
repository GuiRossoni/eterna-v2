import 'package:flutter/material.dart';
import '../molecules/rating_bar.dart';
import '../molecules/comment_item.dart';
import 'book_header.dart';
import '../../services/book_service.dart';

class BookDetailsContent extends StatefulWidget {
  final String heroTag;
  final String? imageAsset;
  final String? imageUrl;
  final String title;
  final String synopsis;
  final String? workKey;
  final List<String> authors;
  final int? year;

  const BookDetailsContent({
    super.key,
    required this.heroTag,
    this.imageAsset,
    this.imageUrl,
    required this.title,
    required this.synopsis,
    this.workKey,
    this.authors = const [],
    this.year,
  });

  @override
  State<BookDetailsContent> createState() => _BookDetailsContentState();
}

class _BookDetailsContentState extends State<BookDetailsContent> {
  int rating = 0;
  Future<WorkDetails?>? _detailsFuture;

  @override
  void initState() {
    super.initState();
    if (widget.workKey != null && widget.workKey!.isNotEmpty) {
      _detailsFuture = BookService().fetchWorkDetails(widget.workKey!);
    }
  }

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
        // Metadados: autores e ano
        if (widget.authors.isNotEmpty || widget.year != null) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (widget.authors.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person, size: 16),
                    const SizedBox(width: 6),
                    Text(widget.authors.join(', ')),
                  ],
                ),
              if (widget.year != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 6),
                    Text('${widget.year}'),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        // Descrição e assuntos via Open Library (quando houver workKey)
        if (_detailsFuture != null)
          FutureBuilder<WorkDetails?>(
            future: _detailsFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: LinearProgressIndicator(minHeight: 2),
                );
              }
              if (snap.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Não foi possível carregar mais detalhes.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.redAccent),
                  ),
                );
              }
              final details = snap.data;
              if (details == null) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (details.description != null &&
                      details.description!.isNotEmpty) ...[
                    Text(
                      'Descrição',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(details.description!),
                    const SizedBox(height: 12),
                  ],
                  if (details.subjects.isNotEmpty) ...[
                    Text(
                      'Assuntos',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          details.subjects
                              .take(12)
                              .map((s) => Chip(label: Text(s)))
                              .toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              );
            },
          ),
        RatingBar(rating: rating, onChange: (r) => setState(() => rating = r)),
        const SizedBox(height: 20),
        Text('Comentários:', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 10),
        ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            CommentItem(user: 'Maria', stars: 5, text: 'Amei esse livro!'),
            CommentItem(
              user: 'João',
              stars: 4,
              text: 'Muito bom, mas poderia ser menor.',
            ),
          ],
        ),
      ],
    );
  }
}
