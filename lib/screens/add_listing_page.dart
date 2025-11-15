import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/listing_model.dart';
import '../widgets/shared.dart';
import '../presentation/state/providers.dart';
import '../services/book_service.dart';
import '../components/organisms/remote_book_picker.dart';
import '../components/organisms/listing_type_section.dart';

class AddListingPage extends ConsumerStatefulWidget {
  const AddListingPage({super.key});

  @override
  ConsumerState<AddListingPage> createState() => _AddListingPageState();
}

class _AddListingPageState extends ConsumerState<AddListingPage> {
  // Form & controllers for listing specific (not book metadata input anymore)
  final _formKey = GlobalKey<FormState>();
  final _priceCtrl = TextEditingController();
  final _exchangeCtrl = TextEditingController(); // manual fallback

  ListingType _type = ListingType.sale;
  bool _loading = false; // submitting listing

  RemoteBook? _selected; // chosen book
  RemoteBook? _swapSelected; // chosen desired book

  @override
  void dispose() {
    _priceCtrl.dispose();
    _exchangeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um livro da busca.')),
      );
      return;
    }
    // Derive exchangeWanted from swap selection or manual fallback
    String? derivedExchangeWanted;
    if (_type == ListingType.swap) {
      if (_swapSelected != null) {
        derivedExchangeWanted = _swapSelected!.title;
      } else if (_exchangeCtrl.text.trim().isNotEmpty) {
        derivedExchangeWanted = _exchangeCtrl.text.trim();
      }
      if (derivedExchangeWanted == null || derivedExchangeWanted.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Informe o livro desejado para troca.')),
        );
        return;
      }
    }
    setState(() => _loading = true);
    final svc = ref.read(listingServiceProvider);
    try {
      final price =
          _type == ListingType.sale
              ? double.tryParse(_priceCtrl.text.replaceAll(',', '.'))
              : null;
      final exchangeWanted =
          _type == ListingType.swap ? derivedExchangeWanted : null;
      await svc.addListing(
        title: _selected!.title,
        authors: _selected!.authors,
        synopsis: _selected!.synopsis,
        imageUrl: _selected!.imageUrl.isEmpty ? null : _selected!.imageUrl,
        type: _type,
        price: price,
        exchangeWanted: exchangeWanted,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Anúncio criado!')));
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
      appBar: AppBar(title: const Text('Novo Anúncio')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: GlassPanel(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RemoteBookPicker(
                    title: 'Escolha um livro (Open Library)',
                    selected: _selected,
                    onSelected: (book) => setState(() => _selected = book),
                    onSearch:
                        (query) => ref
                            .read(bookServiceProvider)
                            .search(query, limit: 10, page: 1),
                  ),
                  const SizedBox(height: 24),
                  ListingTypeSection(
                    type: _type,
                    onTypeChanged: (v) => setState(() => _type = v),
                    priceController: _priceCtrl,
                    exchangeController: _exchangeCtrl,
                    priceValidator: (v) {
                      if (_type != ListingType.sale) return null;
                      if (v == null || v.trim().isEmpty) {
                        return 'Informe o preço';
                      }
                      final value = double.tryParse(v.replaceAll(',', '.'));
                      if (value == null || value <= 0) {
                        return 'Preço inválido';
                      }
                      return null;
                    },
                    showSwapExchangeField: false,
                  ),
                  if (_type == ListingType.swap) ...[
                    const SizedBox(height: 16),
                    RemoteBookPicker(
                      title: 'Livro desejado em troca',
                      searchLabel: 'Buscar na Open Library',
                      selected: _swapSelected,
                      onSelected:
                          (book) => setState(() => _swapSelected = book),
                      onSearch:
                          (query) => ref
                              .read(bookServiceProvider)
                              .search(query, limit: 10, page: 1),
                      manualController: _exchangeCtrl,
                      manualLabel: 'Ou digite manualmente',
                      manualValidator: (v) {
                        if (_type != ListingType.swap) return null;
                        if (_swapSelected == null &&
                            (v == null || v.trim().isEmpty)) {
                          return 'Busque e selecione ou digite o livro';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _submit,
                      icon: const Icon(Icons.save),
                      label: Text(_loading ? 'Salvando...' : 'Salvar Anúncio'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_selected == null) ...[
                    Text(
                      'Selecione um livro para continuar.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
