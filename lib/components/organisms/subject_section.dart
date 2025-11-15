import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run/presentation/state/providers.dart';
import '../../models/book_model.dart';
import 'book_section.dart';
import '../atoms/book_cover_skeleton.dart';

/// Shows books fetched by Open Library subject.
class SubjectSection extends ConsumerWidget {
  final String title;
  final String subject;
  final void Function(BookModel book, String heroTag) onSelect;

  const SubjectSection({
    super.key,
    required this.title,
    required this.subject,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncBooks = ref.watch(subjectBooksProvider(subject));
    return asyncBooks.when(
      data: (books) {
        if (books.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('Nenhum livro encontrado para "$subject"'),
          );
        }
        return BookSection(
          title: title,
          books: books,
          onSelect: (b, hero) => onSelect(b, hero),
        );
      },
      loading: () => _SkeletonStrip(height: 160),
      error:
          (err, stack) => Row(
            children: [
              Expanded(
                child: Text(
                  'Erro ao carregar "$subject": $err',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.redAccent),
                ),
              ),
              IconButton(
                tooltip: 'Tentar novamente',
                onPressed: () => ref.invalidate(subjectBooksProvider(subject)),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
    );
  }
}

class _SkeletonStrip extends StatelessWidget {
  final double height;
  const _SkeletonStrip({required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, __) => const BookCoverSkeleton(),
      ),
    );
  }
}
