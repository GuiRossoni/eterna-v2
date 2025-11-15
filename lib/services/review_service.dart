import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/review_model.dart';

class ReviewService {
  final FirebaseFirestore? _firestoreOverride;
  final FirebaseAuth? _authOverride;

  ReviewService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestoreOverride = firestore,
      _authOverride = auth;

  FirebaseFirestore? get _firestore {
    if (_firestoreOverride != null) return _firestoreOverride;
    if (Firebase.apps.isEmpty) return null;
    return FirebaseFirestore.instance;
  }

  FirebaseAuth? get _auth {
    if (_authOverride != null) return _authOverride;
    if (Firebase.apps.isEmpty) return null;
    return FirebaseAuth.instance;
  }

  CollectionReference<Map<String, dynamic>>? _reviewCollection(
    String reviewKey,
  ) {
    final firestore = _firestore;
    if (firestore == null) return null;
    return firestore
        .collection('book_reviews')
        .doc(reviewKey)
        .collection('entries');
  }

  Stream<List<WorkReview>> watchReviews(String reviewKey) {
    if (reviewKey.isEmpty) return _emptyReviewsStream();
    final collection = _reviewCollection(reviewKey);
    if (collection == null) return _emptyReviewsStream();
    return collection.orderBy('createdAt', descending: true).snapshots().map((
      snapshot,
    ) {
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

  Stream<List<WorkReview>> _emptyReviewsStream() =>
      Stream<List<WorkReview>>.value(const <WorkReview>[]);

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
    final collection = _reviewCollection(reviewKey);
    final auth = _auth;
    if (collection == null || auth == null) {
      throw StateError('Firebase não está configurado nesta build.');
    }
    final user = auth.currentUser;
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
    await collection.add(data);
  }
}
