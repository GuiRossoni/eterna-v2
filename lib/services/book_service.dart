import 'dart:convert';
import 'package:http/http.dart' as http;

class RemoteBook {
  final String title;
  final String imageUrl;
  final String synopsis;

  const RemoteBook({
    required this.title,
    required this.imageUrl,
    required this.synopsis,
  });
}

class BookService {
  static const _base = 'https://openlibrary.org';
  static const _covers = 'https://covers.openlibrary.org';

  Future<List<RemoteBook>> search(
    String query, {
    int limit = 10,
    int page = 1,
  }) async {
    final uri = Uri.parse(
      '$_base/search.json?q=${Uri.encodeQueryComponent(query)}&limit=$limit&page=$page',
    );
    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Erro ao buscar livros: ${resp.statusCode}');
    }
    final data = json.decode(resp.body) as Map<String, dynamic>;
    final docs =
        (data['docs'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    return docs.map((doc) {
      final title = (doc['title'] ?? '').toString();
      final isbns =
          (doc['isbn'] as List?)?.map((e) => e.toString()).toList() ?? const [];
      final editionKeys =
          (doc['edition_key'] as List?)?.map((e) => e.toString()).toList() ??
          const [];
      final coverEdition =
          (doc['cover_edition_key'] ??
                  (editionKeys.isNotEmpty ? editionKeys.first : ''))
              as String? ??
          '';
      final imageUrl =
          isbns.isNotEmpty
              ? '$_covers/b/isbn/${isbns.first}-M.jpg'
              : (coverEdition.isNotEmpty
                  ? '$_covers/b/olid/$coverEdition-M.jpg'
                  : '');
      final synopsis =
          (doc['first_sentence'] is String)
              ? doc['first_sentence'] as String
              : 'Livro encontrado na Open Library.';
      return RemoteBook(title: title, imageUrl: imageUrl, synopsis: synopsis);
    }).toList();
  }
}
