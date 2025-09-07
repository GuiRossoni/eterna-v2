import 'package:flutter/material.dart';

class BookDetailsPage extends StatefulWidget {
  const BookDetailsPage({super.key});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  int rating = 0;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final heroTag = args['heroTag'] ?? 'book-cover';
    return Scaffold(
      appBar: AppBar(title: Text(args['title'] ?? "Detalhes do Livro")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Hero(
                  tag: heroTag,
                  child: Semantics(
                    image: true,
                    label: 'Capa do livro',
                    child: Container(
                      width: 150,
                      height: 220,
                      color: Colors.grey[300],
                      child: const Icon(Icons.book, size: 60),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    args['sinopse'] ?? "",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    Icons.star,
                    color: index < rating ? Colors.amber : Colors.grey[400],
                  ),
                  tooltip: 'Avaliar com ${index + 1} estrelas',
                  onPressed: () {
                    setState(() {
                      rating = index + 1;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 20),
            Text(
              "Comentários:",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  _buildComment("Maria", 5, "Amei esse livro!"),
                  _buildComment("João", 4, "Muito bom, mas poderia ser menor."),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComment(String user, int stars, String text) {
    return Card(
      child: ListTile(
        title: Row(
          children: [
            Text(user, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Row(
              children: List.generate(
                5,
                (i) => Icon(
                  Icons.star,
                  size: 16,
                  color: i < stars ? Colors.amber : Colors.grey[400],
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(text),
      ),
    );
  }
}
