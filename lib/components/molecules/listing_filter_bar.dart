import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run/presentation/state/providers.dart';

/// Filter/search bar used to narrow user listings.
class ListingFilterBar extends ConsumerStatefulWidget {
  const ListingFilterBar({super.key});

  @override
  ConsumerState<ListingFilterBar> createState() => _ListingFilterBarState();
}

class _ListingFilterBarState extends ConsumerState<ListingFilterBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final initial = ref.read(listingsFilterQueryProvider);
    _controller = TextEditingController(text: initial)
      ..addListener(_handleChange);
  }

  void _handleChange() {
    final controller = ref.read(listingsFilterQueryProvider.notifier);
    final text = _controller.text;
    if (controller.state != text) {
      controller.state = text;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(listingsFilterQueryProvider);
    if (query != _controller.text) {
      _controller.value = _controller.value.copyWith(
        text: query,
        selection: TextSelection.collapsed(offset: query.length),
      );
    }
    final order = ref.watch(saleOrderProvider);
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              labelText: 'Filtrar anúncios por título/autor',
              prefixIcon: const Icon(Icons.filter_list),
              suffixIcon:
                  query.isNotEmpty
                      ? IconButton(
                        tooltip: 'Limpar filtro',
                        onPressed:
                            () =>
                                ref
                                    .read(listingsFilterQueryProvider.notifier)
                                    .state = '',
                        icon: const Icon(Icons.clear),
                      )
                      : null,
            ),
          ),
        ),
        const SizedBox(width: 12),
        DropdownButton<SaleOrder>(
          value: order,
          onChanged: (v) {
            if (v != null) {
              ref.read(saleOrderProvider.notifier).state = v;
            }
          },
          items: const [
            DropdownMenuItem(
              value: SaleOrder.recent,
              child: Text('Mais recentes'),
            ),
            DropdownMenuItem(value: SaleOrder.priceAsc, child: Text('Preço ↑')),
            DropdownMenuItem(
              value: SaleOrder.priceDesc,
              child: Text('Preço ↓'),
            ),
          ],
        ),
      ],
    );
  }
}
