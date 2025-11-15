import 'package:flutter_test/flutter_test.dart';
import 'package:run/services/review_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReviewService fallback', () {
    test(
      'watchReviews retorna lista vazia quando Firebase não está pronto',
      () async {
        final service = ReviewService();
        final items = await service.watchReviews('qualquer').first;
        expect(items, isEmpty);
      },
    );

    test('submitReview avisa quando Firebase não está configurado', () async {
      final service = ReviewService();
      await expectLater(
        service.submitReview(
          reviewKey: 'qualquer',
          text: 'Muito bom',
          rating: 4,
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
