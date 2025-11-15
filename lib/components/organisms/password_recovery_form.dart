import 'package:flutter/material.dart';
import '../../services/firebase_auth_service.dart';

/// Form used to send password recovery emails.
class PasswordRecoveryForm extends StatefulWidget {
  final VoidCallback? onSuccess;

  const PasswordRecoveryForm({super.key, this.onSuccess});

  @override
  State<PasswordRecoveryForm> createState() => _PasswordRecoveryFormState();
}

class _PasswordRecoveryFormState extends State<PasswordRecoveryForm> {
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

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final messenger = ScaffoldMessenger.of(context);
    final value = _controller.text.trim();
    try {
      final ok = await FirebaseAuthService.ensureInitialized();
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
      await showDialog<void>(
        context: context,
        builder:
            (dialogCtx) => AlertDialog(
              content: Text('E-mail de recuperação enviado para $value'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
      widget.onSuccess?.call();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Falha ao enviar recuperação: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Recuperar Senha',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _controller,
            decoration: const InputDecoration(labelText: 'E-mail cadastrado'),
            validator: _validateInput,
          ),
          const SizedBox(height: 20),
          Semantics(
            button: true,
            label: 'Enviar recuperação de senha',
            child: ElevatedButton(
              onPressed: _submit,
              child: const Text('Enviar'),
            ),
          ),
        ],
      ),
    );
  }
}
