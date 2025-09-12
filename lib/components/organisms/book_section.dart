import 'package:flutter/material.dart';
import '../../models/book_model.dart';
import '../molecules/book_card.dart';

class BookSection extends StatefulWidget {
  final String title;
  final List<BookModel> books;
  final void Function(BookModel, String heroTag) onSelect;
  final VoidCallback? onEndReached;

  const BookSection({
    super.key,
    required this.title,
    required this.books,
    required this.onSelect,
    this.onEndReached,
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
                  return BookCard(
                    sectionTitle: widget.title,
                    heroTag: heroTag,
                    book: book,
                    onTap: () => widget.onSelect(book, heroTag),
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
