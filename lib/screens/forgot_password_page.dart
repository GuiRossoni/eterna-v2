import 'package:flutter/material.dart';
import '../widgets/shared.dart';
import '../services/firebase_auth_service.dart';

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
      appBar: AppBar(
        title: const Text('Recuperar Senha'),
        leading: Semantics(
          label: 'Voltar',
          button: true,
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Voltar',
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
        ),
      ),
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
                    onPressed: () async {
                      if (!(_formKey.currentState?.validate() ?? false)) return;
                      final value = _controller.text.trim();
                      if (value.contains('@')) {
                        try {
                          final ok =
                              await FirebaseAuthService.ensureInitialized();
                          if (!ok) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Firebase não está configurado para web/este ambiente.',
                                ),
                              ),
                            );
                            return;
                          }
                          await FirebaseAuthService().sendPasswordReset(value);
                          if (!mounted) return;
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  content: Text(
                                    'E-mail de recuperação enviado para $value',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Falha ao enviar recuperação: $e'),
                            ),
                          );
                        }
                      } else {
                        // Placeholder: SMS não implementado
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Recuperação por SMS não está configurada.',
                            ),
                          ),
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
