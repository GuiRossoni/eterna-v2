import 'package:flutter/material.dart';

class SearchBarMolecule extends StatefulWidget {
  final void Function(String) onSearch;
  const SearchBarMolecule({super.key, required this.onSearch});

  @override
  State<SearchBarMolecule> createState() => _SearchBarMoleculeState();
}

class _SearchBarMoleculeState extends State<SearchBarMolecule> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _loading = false;

  String? _validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Digite algo para pesquisar';
    }
    if (value.trim().length < 3) return 'Digite pelo menos 3 caracteres';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final query = _controller.text.trim();
    widget.onSearch(query);
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Barra de busca de livros',
      container: true,
      child: Form(
        key: _formKey,
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _controller,
                validator: _validate,
                decoration: const InputDecoration(
                  hintText: 'Pesquisar livros...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Semantics(
              button: true,
              label: 'Executar busca',
              enabled: !_loading,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child:
                    _loading
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Buscar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
