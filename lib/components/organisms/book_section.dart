import 'package:flutter/material.dart';
import '../../models/book_model.dart';
import '../molecules/book_card.dart';

class BookSection extends StatefulWidget {
  final String title;
  final List<BookModel> books;
  final void Function(BookModel, String heroTag) onSelect;
  final VoidCallback? onEndReached;
  final void Function(BookModel)? onAddToCart;
  final void Function(BookModel)? onEditListing;
  final void Function(BookModel)? onDeleteListing;

  const BookSection({
    super.key,
    required this.title,
    required this.books,
    required this.onSelect,
    this.onEndReached,
    this.onAddToCart,
    this.onEditListing,
    this.onDeleteListing,
  });

  @override
  State<BookSection> createState() => _BookSectionState();
}

class _BookSectionState extends State<BookSection> {
  final ScrollController _hController = ScrollController();

  @override
  void dispose() {
    _hController.dispose();
    super.dispose();
  }

  String _buildMeta(BookModel book) {
    if (!book.isListing) return '';
    final user = book.userDisplayName ?? 'Usuário';
    final time = book.timeAgo();
    return 'por $user $time';
  }

  String _buildPrimaryLabel(BookModel book) {
    if (book.listingType == 'swap' && (book.exchangeWanted ?? '').isNotEmpty) {
      return 'Troca por: ${book.exchangeWanted}';
    }
    if (book.listingType == 'donation') {
      return 'Doação';
    }
    if (book.listingType == 'sale' && book.price != null) {
      return 'R\$ ${book.price!.toStringAsFixed(2)}';
    }
    if (book.price != null) {
      return 'R\$ ${book.price!.toStringAsFixed(2)}';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            widget.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 210,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notif) {
              if (notif.metrics.pixels >= notif.metrics.maxScrollExtent - 100) {
                widget.onEndReached?.call();
              }
              return false;
            },
            child: Scrollbar(
              controller: _hController,
              thumbVisibility: true,
              thickness: 4,
              radius: const Radius.circular(6),
              notificationPredicate:
                  (notif) => notif.metrics.axis == Axis.horizontal,
              child: ListView.separated(
                controller: _hController,
                scrollDirection: Axis.horizontal,
                itemCount: widget.books.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final book = widget.books[index];
                  final heroTag = '${widget.title}-${book.title}-$index';
                  final primary = _buildPrimaryLabel(book);
                  final meta = _buildMeta(book);
                  return SizedBox(
                    width: 160,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: BookCard(
                            sectionTitle: widget.title,
                            heroTag: heroTag,
                            book: book,
                            onTap: () => widget.onSelect(book, heroTag),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                [
                                  primary,
                                  meta,
                                ].where((e) => e.isNotEmpty).join(' • '),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                            if (widget.onAddToCart != null &&
                                book.listingType == 'sale' &&
                                book.price != null)
                              IconButton(
                                icon: const Icon(
                                  Icons.add_shopping_cart,
                                  size: 20,
                                ),
                                padding: EdgeInsets.zero,
                                tooltip: 'Adicionar ao carrinho',
                                onPressed: () => widget.onAddToCart!(book),
                              ),
                            if (widget.onEditListing != null && book.isListing)
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                padding: EdgeInsets.zero,
                                tooltip: 'Editar anúncio',
                                onPressed: () => widget.onEditListing!(book),
                              ),
                            if (widget.onDeleteListing != null &&
                                book.isListing)
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                ),
                                color: Colors.redAccent,
                                padding: EdgeInsets.zero,
                                tooltip: 'Remover anúncio',
                                onPressed: () => widget.onDeleteListing!(book),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
