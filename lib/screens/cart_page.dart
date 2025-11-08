import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run/presentation/state/providers.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartStateProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Carrinho')),
      body:
          cart.items.isEmpty
              ? const Center(child: Text('Carrinho vazio'))
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: cart.items.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) {
                  if (i == cart.items.length) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('R\$ ${cart.total.toStringAsFixed(2)}'),
                          ],
                        ),
                      ),
                    );
                  }
                  final item = cart.items[i];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.book.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'R\$ ${(item.book.price ?? 0).toStringAsFixed(2)} x ${item.quantity}',
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed:
                                () => ref
                                    .read(cartStateProvider.notifier)
                                    .decrement(item.book),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed:
                                () => ref
                                    .read(cartStateProvider.notifier)
                                    .add(item.book),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed:
                                () => ref
                                    .read(cartStateProvider.notifier)
                                    .remove(item.book),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      bottomNavigationBar:
          cart.items.isEmpty
              ? null
              : Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            () => ref.read(cartStateProvider.notifier).clear(),
                        icon: const Icon(Icons.clear),
                        label: const Text('Limpar Carrinho'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {}, // TODO: ação de checkout
                        icon: const Icon(Icons.payment),
                        label: const Text('Checkout'),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
