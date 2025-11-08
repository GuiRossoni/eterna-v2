import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run/models/book_model.dart';

class CartItem {
  final BookModel book;
  final int quantity;
  const CartItem(this.book, this.quantity);

  CartItem copyWith({BookModel? book, int? quantity}) =>
      CartItem(book ?? this.book, quantity ?? this.quantity);
  double get subtotal => (book.price ?? 0) * quantity;
}

class CartState {
  final List<CartItem> items;
  const CartState(this.items);

  double get total => items.fold(0, (acc, e) => acc + e.subtotal);
  int get count => items.fold(0, (acc, e) => acc + e.quantity);
}

class CartController extends StateNotifier<CartState> {
  CartController() : super(const CartState([]));

  void add(BookModel book, {int qty = 1}) {
    if (book.price == null) return; // não adiciona itens sem preço
    final existingIndex = state.items.indexWhere(
      (e) => e.book.title == book.title,
    );
    if (existingIndex >= 0) {
      final updated = state.items[existingIndex].copyWith(
        quantity: state.items[existingIndex].quantity + qty,
      );
      final newItems = [...state.items];
      newItems[existingIndex] = updated;
      state = CartState(newItems);
    } else {
      state = CartState([...state.items, CartItem(book, qty)]);
    }
  }

  void remove(BookModel book) {
    state = CartState(
      state.items.where((e) => e.book.title != book.title).toList(),
    );
  }

  void decrement(BookModel book) {
    final idx = state.items.indexWhere((e) => e.book.title == book.title);
    if (idx < 0) return;
    final current = state.items[idx];
    if (current.quantity <= 1) {
      remove(book);
      return;
    }
    final updated = current.copyWith(quantity: current.quantity - 1);
    final newItems = [...state.items];
    newItems[idx] = updated;
    state = CartState(newItems);
  }

  void clear() => state = const CartState([]);
}

final cartProvider = StateNotifierProvider<CartController, CartState>(
  (ref) => CartController(),
);
