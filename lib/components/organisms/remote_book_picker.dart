import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/book_service.dart';

/// Search-and-select widget for RemoteBook entries, with optional manual input.
class RemoteBookPicker extends StatefulWidget {
  final String title;
  final Future<List<RemoteBook>> Function(String query) onSearch;
  final RemoteBook? selected;
  final ValueChanged<RemoteBook?> onSelected;
  final String searchLabel;
  final String? manualLabel;
  final TextEditingController? manualController;
  final FormFieldValidator<String>? manualValidator;

  const RemoteBookPicker({
    super.key,
    required this.title,
    required this.onSearch,
    required this.onSelected,
    this.selected,
    this.searchLabel = 'Buscar título ou autor',
    this.manualLabel,
    this.manualController,
    this.manualValidator,
  });

  @override
  State<RemoteBookPicker> createState() => _RemoteBookPickerState();
}

class _RemoteBookPickerState extends State<RemoteBookPicker> {
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  List<RemoteBook> _results = const [];
  bool _searching = false;
  String _error = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchCtrl.text.trim();
    _debounce?.cancel();
    if (query.isEmpty) {
      setState(() {
        _results = const [];
        _error = '';
        _searching = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 450), () async {
      setState(() {
        _searching = true;
        _error = '';
      });
      try {
        final list = await widget.onSearch(query);
        if (!mounted) return;
        setState(() {
          _results = list;
          _searching = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _error = e.toString();
          _searching = false;
        });
      }
    });
  }

  void _handleSelect(RemoteBook book) {
    widget.onSelected(book);
    widget.manualController?.text = book.title;
    setState(() {
      _searchCtrl.clear();
      _results = const [];
    });
  }

  void _clearSelection() {
    widget.onSelected(null);
    widget.manualController?.clear();
  }

  @override
  Widget build(BuildContext context) {
    final showManualInput =
        widget.manualController != null && widget.manualLabel != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        TextFormField(
          controller: _searchCtrl,
          decoration: InputDecoration(
            labelText: widget.searchLabel,
            prefixIcon: const Icon(Icons.search),
            suffixIcon:
                _searchCtrl.text.isNotEmpty
                    ? IconButton(
                      tooltip: 'Limpar',
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchCtrl.clear();
                          _results = const [];
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
        if (_error.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Erro: $_error',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.redAccent),
          ),
        ],
        const SizedBox(height: 12),
        if (widget.selected != null)
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: ListTile(
              title: Text(widget.selected!.title),
              subtitle: Text(
                [
                  if (widget.selected!.authors.isNotEmpty)
                    widget.selected!.authors.join(', '),
                  widget.selected!.synopsis,
                ].where((e) => e.isNotEmpty).join(' • '),
              ),
              leading:
                  widget.selected!.imageUrl.isNotEmpty
                      ? Image.network(
                        widget.selected!.imageUrl,
                        width: 50,
                        fit: BoxFit.cover,
                      )
                      : const Icon(Icons.book_outlined, size: 40),
              trailing: IconButton(
                tooltip: 'Trocar livro',
                icon: const Icon(Icons.close),
                onPressed: _clearSelection,
              ),
            ),
          )
        else if (_results.isNotEmpty)
          SizedBox(
            height: 260,
            child: ListView.separated(
              itemCount: _results.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final r = _results[i];
                return ListTile(
                  onTap: () => _handleSelect(r),
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
        if (showManualInput) ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.manualController,
            decoration: InputDecoration(
              labelText: widget.manualLabel,
              prefixIcon: const Icon(Icons.text_fields),
            ),
            validator: widget.manualValidator,
          ),
        ],
      ],
    );
  }
}
