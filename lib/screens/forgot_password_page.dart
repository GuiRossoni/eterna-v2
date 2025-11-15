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
      return 'Informe o e-mail';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Digite um e-mail válido';
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
                    labelText: "E-mail cadastrado",
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
                      final messenger = ScaffoldMessenger.of(context);
                      final dialogContext = context;
                      final value = _controller.text.trim();
                      try {
                        final ok =
                            await FirebaseAuthService.ensureInitialized();
                        if (!mounted) return;
                        if (!ok) {
                          messenger.showSnackBar(
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
                        if (!dialogContext.mounted) return;
                        await showDialog<void>(
                          context: dialogContext,
                          builder:
                              (dialogCtx) => AlertDialog(
                                content: Text(
                                  'E-mail de recuperação enviado para $value',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dialogCtx),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Falha ao enviar recuperação: $e'),
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
