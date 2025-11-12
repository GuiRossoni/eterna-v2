import 'dart:convert';
import 'package:http/http.dart' as http;

class RemoteBook {
  final String title;
  final String imageUrl;
  final String synopsis;
  final String? workKey;
  final List<String> authors;
  final int? firstPublishYear;

  const RemoteBook({
    required this.title,
    required this.imageUrl,
    required this.synopsis,
    this.workKey,
    this.authors = const [],
    this.firstPublishYear,
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
      // Try to parse a short synopsis if present in search, fallback to generic
      String synopsis;
      final fs = doc['first_sentence'];
      if (fs is String) {
        synopsis = fs;
      } else if (fs is Map && fs['value'] is String) {
        synopsis = fs['value'] as String;
      } else if (fs is List && fs.isNotEmpty) {
        synopsis = fs.first.toString();
      } else {
        synopsis = 'Livro encontrado na Open Library.';
      }

      // Work key (e.g., /works/OL123W) may appear as 'key' or in 'work_key' list
      final String? workKey =
          (doc['key'] as String?) ??
          (((doc['work_key'] as List?)?.isNotEmpty ?? false)
              ? (doc['work_key'] as List).first.toString()
              : null);

      final authors =
          (doc['author_name'] as List?)?.map((e) => e.toString()).toList() ??
          const [];
      final int? firstPublishYear =
          doc['first_publish_year'] is int
              ? doc['first_publish_year'] as int
              : (doc['first_publish_year'] is String
                  ? int.tryParse(doc['first_publish_year'] as String)
                  : null);

      return RemoteBook(
        title: title,
        imageUrl: imageUrl,
        synopsis: synopsis,
        workKey: workKey,
        authors: authors,
        firstPublishYear: firstPublishYear,
      );
    }).toList();
  }

  // Details fetched from a specific Work resource
  Future<WorkDetails> fetchWorkDetails(String workKey) async {
    final key = workKey.startsWith('/') ? workKey : '/$workKey';
    final uri = Uri.parse('$_base$key.json');
    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Erro ao carregar detalhes do livro: ${resp.statusCode}');
    }
    final data = json.decode(resp.body) as Map<String, dynamic>;
    // description can be a string or an object { value: "..." }
    String? description;
    final desc = data['description'];
    if (desc is String) {
      description = desc;
    } else if (desc is Map && desc['value'] is String) {
      description = desc['value'] as String;
    }

    // subjects are usually a list of strings
    final subjects =
        (data['subjects'] as List?)?.map((e) => e.toString()).toList() ??
        const [];

    // try to get a year, if available
    int? year;
    final fpd = data['first_publish_date'];
    if (fpd is String && fpd.isNotEmpty) {
      final match = RegExp(r'\d{4}').firstMatch(fpd);
      if (match != null) {
        year = int.tryParse(match.group(0)!);
      }
    }

    return WorkDetails(
      description: description,
      subjects: subjects,
      year: year,
    );
  }

  // Fetch books by subject: https://openlibrary.org/subjects/{subject}.json
  Future<List<RemoteBook>> fetchBySubject(
    String subject, {
    int limit = 12,
    int offset = 0,
  }) async {
    final safeSubject = subject.trim().toLowerCase().replaceAll(' ', '_');
    final uri = Uri.parse(
      '$_base/subjects/$safeSubject.json?limit=$limit&offset=$offset',
    );
    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Erro ao buscar assunto "$subject": ${resp.statusCode}');
    }
    final data = json.decode(resp.body) as Map<String, dynamic>;
    final works =
        (data['works'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    return works.map((w) {
      final title = (w['title'] ?? '').toString();
      final coverId = w['cover_id'];
      final imageUrl = coverId != null ? '$_covers/b/id/$coverId-M.jpg' : '';
      final workKey = (w['key'] ?? '') as String?; // e.g., /works/OL123W
      final authors =
          (w['authors'] as List?)
              ?.map((a) => (a['name'] ?? '').toString())
              .toList() ??
          const [];
      final int? firstPublishYear =
          w['first_publish_year'] is int
              ? w['first_publish_year'] as int
              : null;
      final synopsis = 'Livro do assunto "$subject" na Open Library.';
      return RemoteBook(
        title: title,
        imageUrl: imageUrl,
        synopsis: synopsis,
        workKey: workKey,
        authors: authors,
        firstPublishYear: firstPublishYear,
      );
    }).toList();
  }
}

class WorkDetails {
  final String? description;
  final List<String> subjects;
  final int? year;

  const WorkDetails({this.description, this.subjects = const [], this.year});
}
