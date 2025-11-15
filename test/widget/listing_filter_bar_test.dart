import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:run/components/molecules/listing_filter_bar.dart';
import 'package:run/presentation/state/providers.dart';

void main() {
  testWidgets(
    'ListingFilterBar sincroniza texto e ordenação com os providers',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: ListingFilterBar())),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Senhor dos Anéis');
      await tester.pump();
      expect(container.read(listingsFilterQueryProvider), 'Senhor dos Anéis');

      final clearButton = find.byIcon(Icons.clear);
      expect(clearButton, findsOneWidget);
      await tester.tap(clearButton);
      await tester.pump();
      expect(container.read(listingsFilterQueryProvider), isEmpty);

      final dropdown = find.byType(DropdownButton<SaleOrder>);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Preço ↑').last);
      await tester.pumpAndSettle();

      expect(container.read(saleOrderProvider), SaleOrder.priceAsc);
    },
  );
}
