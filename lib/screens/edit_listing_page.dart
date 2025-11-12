import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/listing_model.dart';
import '../widgets/shared.dart';
import '../presentation/state/providers.dart';

class EditListingPage extends ConsumerStatefulWidget {
  final Map args;
  const EditListingPage({super.key, required this.args});

  @override
  ConsumerState<EditListingPage> createState() => _EditListingPageState();
}

class _EditListingPageState extends ConsumerState<EditListingPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _authorsCtrl;
  late final TextEditingController _synopsisCtrl;
  late final TextEditingController _imageUrlCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _exchangeCtrl;
  late ListingType _type;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final a = widget.args;
    _titleCtrl = TextEditingController(text: a['title']?.toString() ?? '');
    _authorsCtrl = TextEditingController(
      text: (a['authors'] as List?)?.join(', ') ?? '',
    );
    _synopsisCtrl = TextEditingController(
      text: a['synopsis']?.toString() ?? '',
    );
    _imageUrlCtrl = TextEditingController(
      text: a['imageUrl']?.toString() ?? '',
    );
    _priceCtrl = TextEditingController(
      text: a['price'] == null ? '' : (a['price'] as num).toString(),
    );
    _exchangeCtrl = TextEditingController(
      text: a['exchangeWanted']?.toString() ?? '',
    );
    _type = switch ((a['type']?.toString() ?? 'donation')) {
      'sale' => ListingType.sale,
      'swap' => ListingType.swap,
      _ => ListingType.donation,
    };
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _authorsCtrl.dispose();
    _synopsisCtrl.dispose();
    _imageUrlCtrl.dispose();
    _priceCtrl.dispose();
    _exchangeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    final svc = ref.read(listingServiceProvider);
    try {
      final id = widget.args['id']?.toString();
      if (id == null || id.isEmpty) throw 'ID inválido';
      final authors =
          _authorsCtrl.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
      await svc.updateListing(
        id,
        title: _titleCtrl.text.trim(),
        authors: authors,
        synopsis: _synopsisCtrl.text.trim(),
        imageUrl: _imageUrlCtrl.text.trim(),
        price:
            _type == ListingType.sale ? double.tryParse(_priceCtrl.text) : null,
        exchangeWanted:
            _type == ListingType.swap ? _exchangeCtrl.text.trim() : null,
        type: _type,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Anúncio atualizado.')));
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Anúncio')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: GlassPanel(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      prefixIcon: Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _authorsCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Autores (separados por vírgula)',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _synopsisCtrl,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Sinopse',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _imageUrlCtrl,
                    decoration: const InputDecoration(
                      labelText: 'URL da Imagem (opcional)',
                      prefixIcon: Icon(Icons.image_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<ListingType>(
                    value: _type,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Anúncio',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: ListingType.sale,
                        child: Text('Venda'),
                      ),
                      DropdownMenuItem(
                        value: ListingType.swap,
                        child: Text('Troca'),
                      ),
                      DropdownMenuItem(
                        value: ListingType.donation,
                        child: Text('Doação'),
                      ),
                    ],
                    onChanged: (v) => setState(() => _type = v ?? _type),
                  ),
                  const SizedBox(height: 12),
                  if (_type == ListingType.sale)
                    TextFormField(
                      controller: _priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Preço (R\$)',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                    ),
                  if (_type == ListingType.swap)
                    TextFormField(
                      controller: _exchangeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Livro desejado em troca',
                        prefixIcon: Icon(Icons.swap_horiz),
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _submit,
                      icon: const Icon(Icons.save),
                      label: Text(_loading ? 'Salvando...' : 'Salvar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
