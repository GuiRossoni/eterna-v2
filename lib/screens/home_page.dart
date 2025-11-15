import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run/presentation/state/providers.dart';
import '../widgets/shared.dart';
import '../models/book_model.dart';
import '../components/organisms/book_section.dart';
import '../components/molecules/search_bar.dart';
import '../components/molecules/listing_filter_bar.dart';
import '../components/organisms/listing_section.dart';
import '../components/organisms/subject_section.dart';
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
                  SubjectSection(
                    title: 'Livros em Alta',
                    subject: _subjectTrending,
                    onSelect: _openBookDetails,
                  ),
                  const SizedBox(height: 20),
                  const ListingFilterBar(),
                  const SizedBox(height: 12),
                  ListingSection(
                    title: 'Livros à Venda',
                    type: ListingSectionType.sale,
                    onSelect: _openBookDetails,
                  ),
                  const SizedBox(height: 20),
                  ListingSection(
                    title: 'Livros para Troca',
                    type: ListingSectionType.swap,
                    onSelect: _openBookDetails,
                  ),
                  const SizedBox(height: 20),
                  ListingSection(
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
