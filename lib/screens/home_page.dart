import 'package:flutter/material.dart';
import '../widgets/shared.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildBookRow(
    BuildContext context,
    String title,
    List<String> imagens,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: imagens.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final tag = '$title-$index';
              return Semantics(
                label: 'Abrir detalhes do ${title.toLowerCase()} ${index + 1}',
                button: true,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/book-details',
                      arguments: {
                        'title': 'Livro ${index + 1}',
                        'sinopse': 'Esta é a sinopse do livro ${index + 1}.',
                        'heroTag': tag,
                      },
                    );
                  },
                  child: Hero(
                    tag: tag,
                    child: Container(
                      width: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: AssetImage(imagens[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String? _validateSearch(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Digite algo para pesquisar';
    }
    if (value.trim().length < 3) {
      return 'Digite pelo menos 3 caracteres';
    }
    return null;
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: "Pesquisar livros...",
                            prefixIcon: Icon(Icons.search),
                          ),
                          validator: _validateSearch,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Aqui você pode implementar a lógica de pesquisa
                            FocusScope.of(context).unfocus();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Buscando por: ${_searchController.text.trim()}',
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text('Buscar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Botões de acesso às demonstrações
                  Center(
                    child: Column(
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.science),
                          label: const Text('Demonstração Atomic Design'),
                          onPressed:
                              () =>
                                  Navigator.pushNamed(context, '/atomic-demo'),
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
                  _buildBookRow(context, "Livros em Alta", [
                    'assets/imagens/Livro1.webp',
                    'assets/imagens/Livro2.webp',
                  ]),
                  const SizedBox(height: 20),
                  _buildBookRow(context, "Livros à Venda", [
                    'assets/imagens/Livro3.webp',
                    'assets/imagens/Livro4.webp',
                  ]),
                  const SizedBox(height: 20),
                  _buildBookRow(context, "Livros para Troca", [
                    'assets/imagens/Livro5.jpg',
                    'assets/imagens/Livro6.jpg',
                  ]),
                  const SizedBox(height: 20),
                  _buildBookRow(context, "Livros para Doação", [
                    'assets/imagens/Livro7.jpg',
                    'assets/imagens/Livro8.jpg',
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
