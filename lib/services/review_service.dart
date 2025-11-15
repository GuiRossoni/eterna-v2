import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/review_model.dart';

class ReviewService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ReviewService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _reviewCollection(
    String reviewKey,
  ) {
    return _firestore
        .collection('book_reviews')
        .doc(reviewKey)
        .collection('entries');
  }

  Stream<List<WorkReview>> watchReviews(String reviewKey) {
    if (reviewKey.isEmpty) return const Stream<List<WorkReview>>.empty();
    return _reviewCollection(
      reviewKey,
    ).orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final timestamp = data['createdAt'];
        DateTime? created;
        if (timestamp is Timestamp) {
          created = timestamp.toDate();
        } else if (timestamp is DateTime) {
          created = timestamp;
        }
        return WorkReview(
          user:
              (data['userName'] ?? data['userId'] ?? 'Leitor anônimo')
                  .toString(),
          text: (data['text'] ?? '').toString(),
          rating: (data['rating'] as num?)?.toInt(),
          createdAt: created,
          authorId: data['userId']?.toString(),
        );
      }).toList();
    });
  }

  Future<void> submitReview({
    required String reviewKey,
    required String text,
    required int rating,
    String? overrideName,
  }) async {
    if (reviewKey.isEmpty) {
      throw ArgumentError(
        'reviewKey não pode ser vazio para salvar comentários',
      );
    }
    final user = _auth.currentUser;
    final displayName =
        overrideName?.trim().isNotEmpty == true
            ? overrideName!.trim()
            : (user?.displayName?.trim().isNotEmpty == true
                ? user!.displayName!
                : (user?.email ?? 'Leitor anônimo'));
    final data = {
      'userId': user?.uid,
      'userName': displayName,
      'text': text,
      'rating': rating,
      'createdAt': FieldValue.serverTimestamp(),
    };
    await _reviewCollection(reviewKey).add(data);
  }
}
