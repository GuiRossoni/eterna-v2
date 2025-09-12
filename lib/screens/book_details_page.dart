import 'package:flutter/material.dart';
import '../components/organisms/book_details_content.dart';

class BookDetailsPage extends StatelessWidget {
  const BookDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final title = args?['title'] as String? ?? 'Detalhes do Livro';
    final synopsis = args?['sinopse'] as String? ?? '';
    final heroTag = args?['heroTag'] as String? ?? 'book-cover';
    final imageAsset = args?['imageAsset'] as String?;
    final imageUrl = args?['imageUrl'] as String?;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BookDetailsContent(
          heroTag: heroTag,
          imageAsset: imageAsset,
          imageUrl: imageUrl,
          title: title,
          synopsis: synopsis,
        ),
      ),
    );
  }
}
