import 'package:flutter/material.dart';
import '../../models/listing_model.dart';

/// Dropdown + conditional fields for listing type configuration.
class ListingTypeSection extends StatelessWidget {
  final ListingType type;
  final ValueChanged<ListingType> onTypeChanged;
  final TextEditingController priceController;
  final TextEditingController exchangeController;
  final FormFieldValidator<String>? priceValidator;
  final FormFieldValidator<String>? exchangeValidator;
  final bool showSwapExchangeField;
  final String priceLabel;
  final String exchangeLabel;

  const ListingTypeSection({
    super.key,
    required this.type,
    required this.onTypeChanged,
    required this.priceController,
    required this.exchangeController,
    this.priceValidator,
    this.exchangeValidator,
    this.showSwapExchangeField = true,
    this.priceLabel = 'Preço (R\$)',
    this.exchangeLabel = 'Livro desejado em troca',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownMenu<ListingType>(
          initialSelection: type,
          label: const Text('Tipo de Anúncio'),
          leadingIcon: const Icon(Icons.category_outlined),
          dropdownMenuEntries: const [
            DropdownMenuEntry(value: ListingType.sale, label: 'Venda'),
            DropdownMenuEntry(value: ListingType.swap, label: 'Troca'),
            DropdownMenuEntry(value: ListingType.donation, label: 'Doação'),
          ],
          onSelected: (v) {
            if (v != null) {
              onTypeChanged(v);
            }
          },
        ),
        const SizedBox(height: 12),
        if (type == ListingType.sale)
          TextFormField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: priceLabel,
              prefixIcon: const Icon(Icons.attach_money),
            ),
            validator: priceValidator,
          ),
        if (type == ListingType.swap && showSwapExchangeField)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: TextFormField(
              controller: exchangeController,
              decoration: InputDecoration(
                labelText: exchangeLabel,
                prefixIcon: const Icon(Icons.swap_horiz),
              ),
              validator: exchangeValidator,
            ),
          ),
      ],
    );
  }
}
