import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run/presentation/state/providers.dart';
import '../widgets/shared.dart';
import '../models/book_model.dart';
import '../components/organisms/book_section.dart';
import '../components/molecules/search_bar.dart';
import '../components/atoms/book_cover_skeleton.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _verticalScrollController = ScrollController();
  // Assuntos mapeados (Open Library subjects). Pode ajustar conforme necessidade.
  static const _subjectTrending = 'fantasy';
  // Outros três serão listagens dos usuários (Firestore)

  // Estado de busca agora via Riverpod (SearchController)

  void _openBookDetails(BookModel book, String heroTag) {
    Navigator.pushNamed(
      context,
      '/book-details',
      arguments: {
        'title': book.title,
        'sinopse': book.synopsis,
        'heroTag': heroTag,
        if (book.workKey != null) 'workKey': book.workKey,
        if (book.listingId != null) 'listingId': book.listingId,
        if (book.listingType != null) 'listingType': book.listingType,
        if ((book.exchangeWanted ?? '').isNotEmpty)
          'exchangeWanted': book.exchangeWanted,
        if (book.price != null) 'price': book.price,
        if ((book.userId ?? '').isNotEmpty) 'userId': book.userId,
        if ((book.userDisplayName ?? '').isNotEmpty)
          'ownerName': book.userDisplayName,
        'reviewKey': _reviewKeyFor(book),
        if (book.authors.isNotEmpty) 'authors': book.authors,
        if (book.year != null) 'year': book.year,
        if (book.imageAsset != null) 'imageAsset': book.imageAsset,
        if (book.imageUrl != null) 'imageUrl': book.imageUrl,
      },
    );
  }

  String _reviewKeyFor(BookModel book) {
    final workKey = book.workKey;
    if (workKey != null && workKey.isNotEmpty) {
      return workKey;
    }
    final listingId = book.listingId;
    if (listingId != null && listingId.isNotEmpty) {
      return 'listing:$listingId';
    }
    final normalized = book.title.trim().toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]+'),
      '-',
    );
    return 'title:$normalized';
  }

  // Busca movida para SearchController (Riverpod)

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchControllerProvider);
    final searchCtrl = ref.read(searchControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Biblioteca Virtual"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushNamed(context, '/'),
          tooltip: 'Voltar para login',
        ),
        actions: [
          // Carrinho
          Consumer(
            builder: (context, ref, _) {
              final cart = ref.watch(cartStateProvider);
              return Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    tooltip: 'Carrinho',
                    onPressed: () => Navigator.pushNamed(context, '/cart'),
                  ),
                  if (cart.count > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          cart.count.toString(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Perfil',
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: Center(
        child: Scrollbar(
          controller: _verticalScrollController,
          thumbVisibility: true,
          thickness: 6,
          radius: const Radius.circular(8),
          child: SingleChildScrollView(
            controller: _verticalScrollController,
            padding: const EdgeInsets.all(16),
            child: GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchBarMolecule(
                    onSearch: (query) async {
                      FocusScope.of(context).unfocus();
                      await searchCtrl.search(query);
                    },
                  ),
                  const SizedBox(height: 20),
                  if (searchState.loading)
                    SizedBox(
                      height: 160,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 6,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, __) => const BookCoverSkeleton(),
                      ),
                    ),
                  if (!searchState.loading &&
                      searchState.query.isNotEmpty &&
                      searchState.results.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Nenhum resultado encontrado para "${searchState.query}"',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  if (!searchState.loading &&
                      searchState.results.isNotEmpty) ...[
                    BookSection(
                      title: 'Resultados para "${searchState.query}"',
                      books: searchState.results,
                      onSelect: (b, heroTag) => _openBookDetails(b, heroTag),
                      onEndReached: () {
                        if (!searchState.loading &&
                            !searchState.loadingMore &&
                            searchState.hasMore) {
                          searchCtrl.loadMore();
                        }
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => searchCtrl.clear(),
                        icon: const Icon(Icons.clear),
                        label: const Text('Limpar resultados'),
                      ),
                    ),
                    if (searchState.loadingMore)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],
                  const SizedBox.shrink(),
                  const SizedBox(height: 0),
                  _SubjectSection(
                    title: 'Livros em Alta',
                    subject: _subjectTrending,
                    onSelect: _openBookDetails,
                  ),
                  const SizedBox(height: 20),
                  const _ListingFilterBar(),
                  const SizedBox(height: 12),
                  _ListingSection(
                    title: 'Livros à Venda',
                    type: ListingSectionType.sale,
                    onSelect: _openBookDetails,
                  ),
                  const SizedBox(height: 20),
                  _ListingSection(
                    title: 'Livros para Troca',
                    type: ListingSectionType.swap,
                    onSelect: _openBookDetails,
                  ),
                  const SizedBox(height: 20),
                  _ListingSection(
                    title: 'Livros para Doação',
                    type: ListingSectionType.donation,
                    onSelect: _openBookDetails,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add-listing'),
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Livro'),
      ),
    );
  }
}

class _SubjectSection extends ConsumerWidget {
  final String title;
  final String subject;
  final void Function(BookModel book, String heroTag) onSelect;

  const _SubjectSection({
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
      loading:
          () => SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, __) => const BookCoverSkeleton(),
            ),
          ),
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

enum ListingSectionType { sale, swap, donation }

class _ListingFilterBar extends ConsumerStatefulWidget {
  const _ListingFilterBar();

  @override
  ConsumerState<_ListingFilterBar> createState() => _ListingFilterBarState();
}

class _ListingFilterBarState extends ConsumerState<_ListingFilterBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final initial = ref.read(listingsFilterQueryProvider);
    _controller = TextEditingController(text: initial)
      ..addListener(_handleChange);
  }

  void _handleChange() {
    final controller = ref.read(listingsFilterQueryProvider.notifier);
    final text = _controller.text;
    if (controller.state != text) {
      controller.state = text;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(listingsFilterQueryProvider);
    if (query != _controller.text) {
      _controller.value = _controller.value.copyWith(
        text: query,
        selection: TextSelection.collapsed(offset: query.length),
      );
    }
    final order = ref.watch(saleOrderProvider);
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              labelText: 'Filtrar anúncios por título/autor',
              prefixIcon: const Icon(Icons.filter_list),
              suffixIcon:
                  query.isNotEmpty
                      ? IconButton(
                        tooltip: 'Limpar filtro',
                        onPressed:
                            () =>
                                ref
                                    .read(listingsFilterQueryProvider.notifier)
                                    .state = '',
                        icon: const Icon(Icons.clear),
                      )
                      : null,
            ),
          ),
        ),
        const SizedBox(width: 12),
        DropdownButton<SaleOrder>(
          value: order,
          onChanged: (v) {
            if (v != null) {
              ref.read(saleOrderProvider.notifier).state = v;
            }
          },
          items: const [
            DropdownMenuItem(
              value: SaleOrder.recent,
              child: Text('Mais recentes'),
            ),
            DropdownMenuItem(value: SaleOrder.priceAsc, child: Text('Preço ↑')),
            DropdownMenuItem(
              value: SaleOrder.priceDesc,
              child: Text('Preço ↓'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ListingSection extends ConsumerWidget {
  final String title;
  final ListingSectionType type;
  final void Function(BookModel book, String heroTag) onSelect;

  const _ListingSection({
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
                          return; // próprio anúncio → nada
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
      loading:
          () => SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, __) => const BookCoverSkeleton(),
            ),
          ),
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
