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
  // Dados mockados (poderiam vir de uma API futuramente)
  final List<BookModel> trendingBooks = const [
    BookModel.asset(
      title: 'Livro 1',
      imageAsset: 'assets/imagens/Livro1.webp',
      synopsis: 'Esta é a sinopse do livro 1.',
    ),
    BookModel.asset(
      title: 'Livro 2',
      imageAsset: 'assets/imagens/Livro2.webp',
      synopsis: 'Esta é a sinopse do livro 2.',
    ),
  ];

  final List<BookModel> saleBooks = const [
    BookModel.asset(
      title: 'Livro 3',
      imageAsset: 'assets/imagens/Livro3.webp',
      synopsis: 'Esta é a sinopse do livro 3.',
    ),
    BookModel.asset(
      title: 'Livro 4',
      imageAsset: 'assets/imagens/Livro4.webp',
      synopsis: 'Esta é a sinopse do livro 4.',
    ),
  ];

  final List<BookModel> swapBooks = const [
    BookModel.asset(
      title: 'Livro 5',
      imageAsset: 'assets/imagens/Livro5.jpg',
      synopsis: 'Esta é a sinopse do livro 5.',
    ),
    BookModel.asset(
      title: 'Livro 6',
      imageAsset: 'assets/imagens/Livro6.jpg',
      synopsis: 'Esta é a sinopse do livro 6.',
    ),
  ];

  final List<BookModel> donationBooks = const [
    BookModel.asset(
      title: 'Livro 7',
      imageAsset: 'assets/imagens/Livro7.jpg',
      synopsis: 'Esta é a sinopse do livro 7.',
    ),
    BookModel.asset(
      title: 'Livro 8',
      imageAsset: 'assets/imagens/Livro8.jpg',
      synopsis: 'Esta é a sinopse do livro 8.',
    ),
  ];

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
        if (book.authors.isNotEmpty) 'authors': book.authors,
        if (book.year != null) 'year': book.year,
        if (book.imageAsset != null) 'imageAsset': book.imageAsset,
        if (book.imageUrl != null) 'imageUrl': book.imageUrl,
      },
    );
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
        actions: const [],
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
                  BookSection(
                    title: 'Livros em Alta',
                    books: trendingBooks,
                    onSelect: (b, heroTag) => _openBookDetails(b, heroTag),
                  ),
                  const SizedBox(height: 20),
                  BookSection(
                    title: 'Livros à Venda',
                    books: saleBooks,
                    onSelect: (b, heroTag) => _openBookDetails(b, heroTag),
                  ),
                  const SizedBox(height: 20),
                  BookSection(
                    title: 'Livros para Troca',
                    books: swapBooks,
                    onSelect: (b, heroTag) => _openBookDetails(b, heroTag),
                  ),
                  const SizedBox(height: 20),
                  BookSection(
                    title: 'Livros para Doação',
                    books: donationBooks,
                    onSelect: (b, heroTag) => _openBookDetails(b, heroTag),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
