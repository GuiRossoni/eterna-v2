import 'package:flutter/material.dart';
import '../widgets/shared.dart';
import '../models/book_model.dart';
import '../components/organisms/book_section.dart';
import '../components/molecules/search_bar.dart';
import '../services/book_service.dart';
import '../components/atoms/book_cover_skeleton.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  // Resultados dinâmicos de busca (Open Library)
  List<BookModel> _searchResults = const [];
  bool _searching = false;
  bool _loadingMore = false;
  String _lastQuery = '';
  final Map<String, List<BookModel>> _cache = {};
  int _currentPage = 1;
  final int _pageSize = 12;
  bool _hasMore = false;

  void _openBookDetails(BookModel book, String heroTag) {
    Navigator.pushNamed(
      context,
      '/book-details',
      arguments: {
        'title': book.title,
        'sinopse': book.synopsis,
        'heroTag': heroTag,
        if (book.imageAsset != null) 'imageAsset': book.imageAsset,
        if (book.imageUrl != null) 'imageUrl': book.imageUrl,
      },
    );
  }

  Future<BookService> _loadService() async {
    // Poderia injetar via locator; aqui retornamos instância simples
    return BookService();
  }

  Future<void> _performSearch(String query, {bool reset = true}) async {
    if (query.trim().isEmpty) return;
    if (!reset && _loadingMore) return; // evita chamadas concorrentes
    if (reset) {
      setState(() {
        _searching = true;
        _loadingMore = false;
        _lastQuery = query;
        _currentPage = 1;
        _hasMore = false;
        _searchResults = const [];
      });
    } else {
      setState(() {
        _loadingMore = true;
      });
    }

    try {
      if (reset && _cache.containsKey(query)) {
        final cached = _cache[query]!;
        setState(() {
          _searchResults = cached;
          _hasMore = cached.length >= _pageSize;
        });
      } else {
        final svc = await _loadService();
        final pageToLoad = reset ? 1 : (_currentPage + 1);
        final items = await svc.search(
          query,
          limit: _pageSize,
          page: pageToLoad,
        );
        final mapped =
            items
                .map(
                  (r) => BookModel.network(
                    title: r.title,
                    imageUrl: r.imageUrl,
                    synopsis: r.synopsis,
                  ),
                )
                .toList();
        setState(() {
          if (reset) {
            _searchResults = mapped;
            _cache[query] = mapped; // cache apenas da primeira página
            _currentPage = 1;
          } else {
            _searchResults = List.of(_searchResults)..addAll(mapped);
            _currentPage = pageToLoad;
          }
          _hasMore = mapped.length >= _pageSize;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro na busca: $e')));
    } finally {
      if (!mounted) return;
      setState(() {
        if (reset) {
          _searching = false;
        } else {
          _loadingMore = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchBarMolecule(
                  onSearch: (query) async {
                    FocusScope.of(context).unfocus();
                    await _performSearch(query, reset: true);
                  },
                ),
                const SizedBox(height: 20),
                if (_searching)
                  SizedBox(
                    height: 160,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 6,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, __) => const BookCoverSkeleton(),
                    ),
                  ),
                if (!_searching &&
                    _lastQuery.isNotEmpty &&
                    _searchResults.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Nenhum resultado encontrado para "$_lastQuery"',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                if (!_searching && _searchResults.isNotEmpty) ...[
                  BookSection(
                    title: 'Resultados para "$_lastQuery"',
                    books: _searchResults,
                    onSelect: (b, heroTag) => _openBookDetails(b, heroTag),
                    onEndReached: () {
                      if (!_searching && !_loadingMore && _hasMore) {
                        _performSearch(_lastQuery, reset: false);
                      }
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed:
                          () => setState(() {
                            _searchResults = const [];
                            _lastQuery = '';
                            _hasMore = false;
                            _currentPage = 1;
                          }),
                      icon: const Icon(Icons.clear),
                      label: const Text('Limpar resultados'),
                    ),
                  ),
                  if (_loadingMore)
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
    );
  }
}
