import 'package:flutter/material.dart';
import '../widgets/shared.dart';
import '../models/book_model.dart';
import '../components/organisms/book_section.dart';
import '../components/molecules/search_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Dados mockados (poderiam vir de uma API futuramente)
  final List<BookModel> trendingBooks = const [
    BookModel(
      title: 'Livro 1',
      imageAsset: 'assets/imagens/Livro1.webp',
      synopsis: 'Esta é a sinopse do livro 1.',
    ),
    BookModel(
      title: 'Livro 2',
      imageAsset: 'assets/imagens/Livro2.webp',
      synopsis: 'Esta é a sinopse do livro 2.',
    ),
  ];

  final List<BookModel> saleBooks = const [
    BookModel(
      title: 'Livro 3',
      imageAsset: 'assets/imagens/Livro3.webp',
      synopsis: 'Esta é a sinopse do livro 3.',
    ),
    BookModel(
      title: 'Livro 4',
      imageAsset: 'assets/imagens/Livro4.webp',
      synopsis: 'Esta é a sinopse do livro 4.',
    ),
  ];

  final List<BookModel> swapBooks = const [
    BookModel(
      title: 'Livro 5',
      imageAsset: 'assets/imagens/Livro5.jpg',
      synopsis: 'Esta é a sinopse do livro 5.',
    ),
    BookModel(
      title: 'Livro 6',
      imageAsset: 'assets/imagens/Livro6.jpg',
      synopsis: 'Esta é a sinopse do livro 6.',
    ),
  ];

  final List<BookModel> donationBooks = const [
    BookModel(
      title: 'Livro 7',
      imageAsset: 'assets/imagens/Livro7.jpg',
      synopsis: 'Esta é a sinopse do livro 7.',
    ),
    BookModel(
      title: 'Livro 8',
      imageAsset: 'assets/imagens/Livro8.jpg',
      synopsis: 'Esta é a sinopse do livro 8.',
    ),
  ];

  void _openBookDetails(BookModel book, String section) {
    final heroTag = '${section}-${book.title}';
    Navigator.pushNamed(
      context,
      '/book-details',
      arguments: {
        'title': book.title,
        'sinopse': book.synopsis,
        'heroTag': heroTag,
        'imageAsset': book.imageAsset,
      },
    );
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
        actions: [
          IconButton(
            icon: const Icon(Icons.science),
            tooltip: 'Demonstração Atomic Design',
            onPressed: () => Navigator.pushNamed(context, '/atomic-demo'),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchBarMolecule(
                  onSearch: (query) {
                    FocusScope.of(context).unfocus();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Buscando por: $query')),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.science),
                        label: const Text('Demonstração Atomic Design'),
                        onPressed:
                            () => Navigator.pushNamed(context, '/atomic-demo'),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.cloud_download),
                        label: const Text('Demonstração Consumo de API'),
                        onPressed:
                            () => Navigator.pushNamed(context, '/api-demo'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                BookSection(
                  title: 'Livros em Alta',
                  books: trendingBooks,
                  onSelect: (b) => _openBookDetails(b, 'Livros em Alta'),
                ),
                const SizedBox(height: 20),
                BookSection(
                  title: 'Livros à Venda',
                  books: saleBooks,
                  onSelect: (b) => _openBookDetails(b, 'Livros à Venda'),
                ),
                const SizedBox(height: 20),
                BookSection(
                  title: 'Livros para Troca',
                  books: swapBooks,
                  onSelect: (b) => _openBookDetails(b, 'Livros para Troca'),
                ),
                const SizedBox(height: 20),
                BookSection(
                  title: 'Livros para Doação',
                  books: donationBooks,
                  onSelect: (b) => _openBookDetails(b, 'Livros para Doação'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
