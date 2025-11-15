import 'package:flutter_test/flutter_test.dart';
import 'package:run/models/book_model.dart';
import 'package:run/presentation/state/cart.dart';

void main() {
  group('CartController', () {
    late CartController controller;
    const pricedBook = BookModel.network(
      title: 'Livro Pago',
      imageUrl: 'https://example.com/paid.jpg',
      synopsis: 'Uma sinopse qualquer',
      price: 25.0,
      authors: ['Autor'],
    );
    const otherBook = BookModel.network(
      title: 'Outro Livro',
      imageUrl: 'https://example.com/other.jpg',
      synopsis: 'Outra sinopse',
      price: 10.0,
    );

    setUp(() {
      controller = CartController();
    });

    test('adiciona itens e incrementa a quantidade quando já existem', () {
      controller.add(pricedBook);
      expect(controller.state.items.length, 1);
      expect(controller.state.items.single.quantity, 1);
      expect(controller.state.total, 25);

      controller.add(pricedBook);
      expect(controller.state.items.single.quantity, 2);
      expect(controller.state.total, 50);
      expect(controller.state.count, 2);
    });

    test('remove e decrementa respeitando o limite mínimo', () {
      controller.add(pricedBook, qty: 2);
      controller.decrement(pricedBook);
      expect(controller.state.items.single.quantity, 1);

      controller.decrement(pricedBook);
      expect(controller.state.items, isEmpty);
      expect(controller.state.total, 0);
    });

    test('remove item específico e limpa carrinho', () {
      controller.add(pricedBook);
      controller.add(otherBook, qty: 3);

      controller.remove(pricedBook);
      expect(controller.state.items.length, 1);
      expect(controller.state.items.first.book.title, otherBook.title);
      expect(controller.state.count, 3);

      controller.clear();
      expect(controller.state.items, isEmpty);
      expect(controller.state.total, 0);
    });

    test('ignora tentativa de adicionar livro sem preço', () {
      const freeBook = BookModel.network(
        title: 'Freebie',
        imageUrl: 'https://example.com/free.jpg',
        synopsis: 'Sem preço',
      );

      controller.add(freeBook);
      expect(controller.state.items, isEmpty);
    });
  });
}
