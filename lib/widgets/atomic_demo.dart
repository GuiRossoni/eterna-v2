import 'package:flutter/material.dart';

/// Átomo: Botão customizado reutilizável
class AtomButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? color;
  final String? semanticLabel;

  const AtomButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.color,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        splashColor: Colors.blueAccent.withOpacity(0.2),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color ?? Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Molécula: Campo de texto com label, ícone e feedback visual
class MoleculeTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final String? semanticLabel;
  final bool obscureText;
  final TextInputType? keyboardType;

  const MoleculeTextField({
    super.key,
    required this.label,
    required this.icon,
    this.controller,
    this.validator,
    this.semanticLabel,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: semanticLabel ?? label,
      child: TextFormField(
        controller: controller,
        validator: validator,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      ),
    );
  }
}

/// Página de demonstração
class AtomicDemoPage extends StatelessWidget {
  const AtomicDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('Atomic Design & Acessibilidade')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Exemplo de Átomo (Botão):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              AtomButton(
                label: 'Clique aqui',
                icon: Icons.touch_app,
                semanticLabel: 'Botão de demonstração',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Microinteração: Botão pressionado!'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              const Text(
                'Exemplo de Molécula (Campo de texto):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              MoleculeTextField(
                label: 'Digite algo',
                icon: Icons.edit,
                controller: controller,
                validator:
                    (v) =>
                        (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
                semanticLabel: 'Campo de texto para digitar',
              ),
              const SizedBox(height: 32),
              const Text(
                'Acessibilidade: Todos os elementos possuem Semantics e contraste adequado.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
