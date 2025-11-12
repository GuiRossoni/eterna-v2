import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/listing_model.dart';

class ListingService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('listings');

  Future<ListingModel> addListing({
    required String title,
    required List<String> authors,
    required String synopsis,
    String? imageUrl,
    required ListingType type,
    double? price,
    String? exchangeWanted,
  }) async {
    final uid = _auth.currentUser?.uid ?? 'anon';
    final displayName = _auth.currentUser?.displayName ?? 'Usuário';
    // Basic validation consistency
    if (type == ListingType.sale && (price == null || price <= 0)) {
      throw ArgumentError('Preço deve ser informado para venda');
    }
    if (type == ListingType.swap &&
        (exchangeWanted == null || exchangeWanted.isEmpty)) {
      throw ArgumentError('Livro desejado deve ser informado para troca');
    }
    final doc = await _col.add({
      'userId': uid,
      'userDisplayName': displayName,
      'title': title,
      'authors': authors,
      'synopsis': synopsis,
      'imageUrl': imageUrl,
      'type': type.name,
      'price': price,
      'exchangeWanted': exchangeWanted,
      'createdAt': FieldValue.serverTimestamp(),
    });
    final snap = await doc.get(const GetOptions(source: Source.server));
    final data = snap.data();
    if (data == null) {
      throw StateError('Falha ao recuperar anúncio recém-criado.');
    }
    return ListingModel.fromMap(snap.id, data);
  }

  Stream<List<ListingModel>> watchByType(ListingType type) {
    return _col
        .where('type', isEqualTo: type.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (query) =>
              query.docs
                  .map((d) => ListingModel.fromMap(d.id, d.data()))
                  .toList(),
        );
  }

  String? get currentUserId => _auth.currentUser?.uid;

  Future<void> updateListing(
    String id, {
    String? title,
    List<String>? authors,
    String? synopsis,
    String? imageUrl,
    double? price,
    String? exchangeWanted,
    ListingType? type,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (authors != null) data['authors'] = authors;
    if (synopsis != null) data['synopsis'] = synopsis;
    if (imageUrl != null) data['imageUrl'] = imageUrl;
    if (price != null) data['price'] = price;
    if (exchangeWanted != null) data['exchangeWanted'] = exchangeWanted;
    if (type != null) data['type'] = type.name;
    if (data.isEmpty) return;
    await _col.doc(id).update(data);
  }

  Future<void> deleteListing(String id) async {
    await _col.doc(id).delete();
  }

  /// Migra anúncios antigos cujo `createdAt` está salvo como String ISO
  /// para Timestamp do Firestore. Retorna o total de documentos atualizados.
  Future<int> migrateLegacyCreatedAt({int batchSize = 500}) async {
    final snap = await _col.limit(batchSize).get();
    int updated = 0;
    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      final data = doc.data();
      final createdAt = data['createdAt'];
      if (createdAt is String) {
        final parsed = DateTime.tryParse(createdAt);
        if (parsed != null) {
          batch.update(doc.reference, {
            'createdAt': Timestamp.fromDate(parsed),
          });
          updated++;
        }
      }
    }
    if (updated > 0) {
      await batch.commit();
    }
    return updated;
  }
}
