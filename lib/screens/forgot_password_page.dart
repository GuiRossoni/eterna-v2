import 'package:flutter/material.dart';
import '../widgets/shared.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validateInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe o e-mail ou número de celular';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    final celularRegex = RegExp(r'^(\(?\d{2}\)?\s)?(\d{4,5}\-?\d{4})$');
    if (!emailRegex.hasMatch(value) && !celularRegex.hasMatch(value)) {
      return 'Digite um e-mail ou celular válido';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: GlassPanel(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Recuperar Senha",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: "Email ou Número de Celular",
                  ),
                  validator: _validateInput,
                ),
                const SizedBox(height: 20),
                Semantics(
                  button: true,
                  label: 'Enviar recuperação de senha',
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: const Text(
                                "Um email ou SMS foi enviado para redefinir sua senha.",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("OK"),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: const Text("Enviar"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
