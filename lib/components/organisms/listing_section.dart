import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run/presentation/state/providers.dart';
import '../../models/book_model.dart';
import '../atoms/book_cover_skeleton.dart';
import 'book_section.dart';

enum ListingSectionType { sale, swap, donation }

/// Consumer widget that renders Firestore listings with filtering hooks.
class ListingSection extends ConsumerWidget {
  final String title;
  final ListingSectionType type;
  final void Function(BookModel book, String heroTag) onSelect;

  const ListingSection({
    super.key,
    required this.title,
    required this.type,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncBooks = switch (type) {
      ListingSectionType.sale => ref.watch(saleListingsProvider),
      ListingSectionType.swap => ref.watch(swapListingsProvider),
      ListingSectionType.donation => ref.watch(donationListingsProvider),
    };
    final authUid = ref.read(listingServiceProvider).currentUserId;
    final isSale = type == ListingSectionType.sale;
    return asyncBooks.when(
      data: (books) {
        if (books.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('Ainda não há anúncios nesta categoria.'),
          );
        }
        final visibleBooks = switch (type) {
          ListingSectionType.sale => ref.watch(
            filteredOrderedSaleListingsProvider,
          ),
          ListingSectionType.swap => ref.watch(filteredSwapListingsProvider),
          ListingSectionType.donation => ref.watch(
            filteredDonationListingsProvider,
          ),
        };
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BookSection(
              title: title,
              books: visibleBooks,
              currentUserId: authUid,
              onSelect: (b, hero) => onSelect(b, hero),
              onAddToCart:
                  isSale
                      ? (b) {
                        if (b.userId == authUid) {
                          return;
                        }
                        ref.read(cartStateProvider.notifier).add(b);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Adicionado ao carrinho: ${b.title}'),
                          ),
                        );
                      }
                      : null,
              onEditListing: (b) {
                if (b.userId != authUid) return;
                Navigator.pushNamed(
                  context,
                  '/edit-listing',
                  arguments: {
                    'id': b.listingId,
                    'type': b.listingType,
                    'title': b.title,
                    'authors': b.authors,
                    'synopsis': b.synopsis,
                    'imageUrl': b.imageUrl,
                    'price': b.price,
                    'exchangeWanted': b.exchangeWanted,
                  },
                );
              },
              onDeleteListing: (b) async {
                if (b.userId != authUid) return;
                final svc = ref.read(listingServiceProvider);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder:
                      (ctx) => AlertDialog(
                        title: const Text('Remover anúncio'),
                        content: Text(
                          'Tem certeza que deseja remover "${b.title}"?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Remover'),
                          ),
                        ],
                      ),
                );
                if (confirmed != true) return;
                try {
                  await svc.deleteListing(b.listingId!);
                  switch (type) {
                    case ListingSectionType.sale:
                      ref.invalidate(saleListingsProvider);
                    case ListingSectionType.swap:
                      ref.invalidate(swapListingsProvider);
                    case ListingSectionType.donation:
                      ref.invalidate(donationListingsProvider);
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Anúncio removido.')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao remover: $e')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
      loading: () => _SkeletonStrip(height: 160),
      error: (err, stack) {
        final msg = err.toString();
        final isIndexIssue =
            msg.contains('requires an index') ||
            msg.toLowerCase().contains('index is current') ||
            msg.toLowerCase().contains('index is currently building');
        final friendly =
            isIndexIssue
                ? 'O índice do Firestore para esta consulta está sendo construído. Isso leva cerca de 1–3 minutos. Tente novamente em instantes.'
                : 'Erro ao carregar anúncios: $msg';
        return Row(
          children: [
            Expanded(
              child: Text(
                friendly,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isIndexIssue ? Colors.orange : Colors.redAccent,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Tentar novamente',
              onPressed: () {
                switch (type) {
                  case ListingSectionType.sale:
                    ref.invalidate(saleListingsProvider);
                  case ListingSectionType.swap:
                    ref.invalidate(swapListingsProvider);
                  case ListingSectionType.donation:
                    ref.invalidate(donationListingsProvider);
                }
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
        );
      },
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
