import 'package:flutter/material.dart';
import '../components/organisms/book_details_content.dart';

class BookDetailsPage extends StatefulWidget {
  const BookDetailsPage({super.key});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final title = args?['title'] as String? ?? 'Detalhes do Livro';
    final synopsis = args?['sinopse'] as String? ?? '';
    final heroTag = args?['heroTag'] as String? ?? 'book-cover';
    final imageAsset = args?['imageAsset'] as String?;
    final imageUrl = args?['imageUrl'] as String?;
    final workKey = args?['workKey'] as String?;
    final authors =
        (args?['authors'] as List?)?.cast<String>() ?? const <String>[];
    final int? year = args?['year'] as int?;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        thickness: 6,
        radius: const Radius.circular(8),
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: BookDetailsContent(
            heroTag: heroTag,
            imageAsset: imageAsset,
            imageUrl: imageUrl,
            title: title,
            synopsis: synopsis,
            workKey: workKey,
            authors: authors,
            year: year,
          ),
        ),
      ),
    );
  }
}
