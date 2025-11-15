import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/listing_model.dart';
import '../widgets/shared.dart';
import '../presentation/state/providers.dart';
import '../services/book_service.dart';

class AddListingPage extends ConsumerStatefulWidget {
  const AddListingPage({super.key});

  @override
  ConsumerState<AddListingPage> createState() => _AddListingPageState();
}

class _AddListingPageState extends ConsumerState<AddListingPage> {
  // Form & controllers for listing specific (not book metadata input anymore)
  final _formKey = GlobalKey<FormState>();
  final _searchCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _exchangeCtrl = TextEditingController(); // manual fallback
  final _swapSearchCtrl = TextEditingController(); // search for desired book

  ListingType _type = ListingType.sale;
  bool _loading = false; // submitting listing

  // Search state
  List<RemoteBook> _results = [];
  bool _searching = false;
  String _searchError = '';
  Timer? _debounce;
  RemoteBook? _selected; // chosen book

  // Swap search state
  List<RemoteBook> _swapResults = [];
  bool _swapSearching = false;
  String _swapError = '';
  Timer? _swapDebounce;
  RemoteBook? _swapSelected; // chosen desired book

  @override
  void dispose() {
    _searchCtrl.dispose();
    _priceCtrl.dispose();
    _exchangeCtrl.dispose();
    _swapSearchCtrl.dispose();
    _debounce?.cancel();
    _swapDebounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchCtrl.text.trim();
    _debounce?.cancel();
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _searchError = '';
        _searching = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 450), () async {
      setState(() {
        _searching = true;
        _searchError = '';
      });
      try {
        final svc = ref.read(bookServiceProvider);
        final list = await svc.search(query, limit: 10, page: 1);
        if (!mounted) return;
        setState(() {
          _results = list;
          _searching = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _searchError = e.toString();
          _searching = false;
        });
      }
    });
  }

  void _onSwapSearchChanged() {
    final query = _swapSearchCtrl.text.trim();
    _swapDebounce?.cancel();
    if (query.isEmpty) {
      setState(() {
        _swapResults = [];
        _swapError = '';
        _swapSearching = false;
      });
      return;
    }
    _swapDebounce = Timer(const Duration(milliseconds: 450), () async {
      setState(() {
        _swapSearching = true;
        _swapError = '';
      });
      try {
        final svc = ref.read(bookServiceProvider);
        final list = await svc.search(query, limit: 10, page: 1);
        if (!mounted) return;
        setState(() {
          _swapResults = list;
          _swapSearching = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _swapError = e.toString();
          _swapSearching = false;
        });
      }
    });
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
                  Text(
                    'Escolha um livro (Open Library)',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      labelText: 'Buscar título ou autor',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon:
                          _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                tooltip: 'Limpar',
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _searchCtrl.clear();
                                    _results = [];
                                    _selected = null;
                                  });
                                },
                              )
                              : null,
                    ),
                    onChanged: (_) => _onSearchChanged(),
                  ),
                  if (_searching) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(minHeight: 3),
                  ],
                  if (_searchError.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Erro: $_searchError',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.redAccent),
                    ),
                  ],
                  const SizedBox(height: 12),
                  if (_selected != null)
                    Card(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: ListTile(
                        title: Text(_selected!.title),
                        subtitle: Text(
                          [
                            if (_selected!.authors.isNotEmpty)
                              _selected!.authors.join(', '),
                            _selected!.synopsis,
                          ].where((e) => e.isNotEmpty).join(' • '),
                        ),
                        leading:
                            _selected!.imageUrl.isNotEmpty
                                ? Image.network(
                                  _selected!.imageUrl,
                                  width: 50,
                                  fit: BoxFit.cover,
                                )
                                : const Icon(Icons.book_outlined, size: 40),
                        trailing: IconButton(
                          tooltip: 'Trocar livro',
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() => _selected = null),
                        ),
                      ),
                    )
                  else if (_results.isNotEmpty) ...[
                    SizedBox(
                      height: 260,
                      child: ListView.separated(
                        itemCount: _results.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (ctx, i) {
                          final r = _results[i];
                          return ListTile(
                            onTap: () => setState(() => _selected = r),
                            leading:
                                r.imageUrl.isNotEmpty
                                    ? Image.network(
                                      r.imageUrl,
                                      width: 50,
                                      fit: BoxFit.cover,
                                    )
                                    : const Icon(Icons.book_outlined, size: 40),
                            title: Text(r.title),
                            subtitle: Text(
                              [
                                if (r.authors.isNotEmpty) r.authors.join(', '),
                                r.synopsis,
                              ].where((e) => e.isNotEmpty).join(' • '),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  DropdownMenu<ListingType>(
                    initialSelection: _type,
                    label: const Text('Tipo de Anúncio'),
                    leadingIcon: const Icon(Icons.category_outlined),
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(
                        value: ListingType.sale,
                        label: 'Venda',
                      ),
                      DropdownMenuEntry(
                        value: ListingType.swap,
                        label: 'Troca',
                      ),
                      DropdownMenuEntry(
                        value: ListingType.donation,
                        label: 'Doação',
                      ),
                    ],
                    onSelected: (v) {
                      if (v == null) return;
                      setState(() => _type = v);
                    },
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
                      validator: (v) {
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
                    ),
                  if (_type == ListingType.swap)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Livro desejado em troca',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _swapSearchCtrl,
                          decoration: InputDecoration(
                            labelText: 'Buscar na Open Library',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon:
                                _swapSearchCtrl.text.isNotEmpty
                                    ? IconButton(
                                      tooltip: 'Limpar',
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() {
                                          _swapSearchCtrl.clear();
                                          _swapResults = [];
                                          _swapSelected = null;
                                        });
                                      },
                                    )
                                    : null,
                          ),
                          onChanged: (_) => _onSwapSearchChanged(),
                        ),
                        if (_swapSearching) ...[
                          const SizedBox(height: 8),
                          const LinearProgressIndicator(minHeight: 2),
                        ],
                        if (_swapError.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Erro: $_swapError',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.redAccent),
                          ),
                        ],
                        const SizedBox(height: 8),
                        if (_swapSelected != null) ...[
                          Card(
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                            child: ListTile(
                              leading:
                                  _swapSelected!.imageUrl.isNotEmpty
                                      ? Image.network(
                                        _swapSelected!.imageUrl,
                                        width: 40,
                                        fit: BoxFit.cover,
                                      )
                                      : const Icon(Icons.book_outlined),
                              title: Text(_swapSelected!.title),
                              subtitle:
                                  _swapSelected!.authors.isNotEmpty
                                      ? Text(_swapSelected!.authors.join(', '))
                                      : null,
                              trailing: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed:
                                    () => setState(() => _swapSelected = null),
                              ),
                            ),
                          ),
                        ] else if (_swapResults.isNotEmpty) ...[
                          SizedBox(
                            height: 220,
                            child: ListView.separated(
                              itemCount: _swapResults.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (ctx, i) {
                                final r = _swapResults[i];
                                return ListTile(
                                  onTap:
                                      () => setState(() {
                                        _swapSelected = r;
                                        _exchangeCtrl.text = r.title;
                                      }),
                                  leading:
                                      r.imageUrl.isNotEmpty
                                          ? Image.network(
                                            r.imageUrl,
                                            width: 40,
                                            fit: BoxFit.cover,
                                          )
                                          : const Icon(Icons.book_outlined),
                                  title: Text(r.title),
                                  subtitle:
                                      r.authors.isNotEmpty
                                          ? Text(r.authors.join(', '))
                                          : null,
                                );
                              },
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _exchangeCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Ou digite manualmente',
                            prefixIcon: Icon(Icons.text_fields),
                          ),
                          validator: (v) {
                            if (_type != ListingType.swap) return null;
                            if ((_swapSelected == null) &&
                                (v == null || v.trim().isEmpty)) {
                              return 'Busque e selecione ou digite o livro';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
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
