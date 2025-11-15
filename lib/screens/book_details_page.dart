import 'package:flutter/material.dart';
import '../components/organisms/book_details_content.dart';

class BookDetailsPage extends StatefulWidget {
  const BookDetailsPage({super.key});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  final ScrollController _scrollController = ScrollController();

  String _resolveReviewKey(
    Map<String, dynamic>? args,
    String title,
    String? workKey,
  ) {
    final explicit = (args?['reviewKey'] as String?)?.trim();
    if (explicit != null && explicit.isNotEmpty) return explicit;
    if (workKey != null && workKey.isNotEmpty) return workKey;
    final listingId = (args?['listingId'] as String?)?.trim();
    if (listingId != null && listingId.isNotEmpty) {
      return 'listing:$listingId';
    }
    final normalized = title.trim().toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]+'),
      '-',
    );
    return 'title:$normalized';
  }

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
    final listingId = args?['listingId'] as String?;
    final listingType = args?['listingType'] as String?;
    final exchangeWanted = args?['exchangeWanted'] as String?;
    final double? price =
        args?['price'] is num ? (args?['price'] as num).toDouble() : null;
    final ownerName = args?['ownerName'] as String?;
    final ownerId = args?['userId'] as String?;
    final reviewKey = _resolveReviewKey(args, title, workKey);
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
            reviewKey: reviewKey,
            authors: authors,
            year: year,
            listingType: listingType,
            listingId: listingId,
            exchangeWanted: exchangeWanted,
            price: price,
            ownerName: ownerName,
            ownerId: ownerId,
          ),
        ),
      ),
    );
  }
}
