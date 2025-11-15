import 'package:flutter/material.dart';
import '../molecules/app_text_field.dart';
import '../atoms/app_button.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_auth_service.dart';

/// Complete registration form reused inside auth screens.
class RegisterForm extends StatefulWidget {
  final VoidCallback? onSuccess;

  const RegisterForm({super.key, this.onSuccess});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _senhaConfirmController = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _senhaController.addListener(_validatePasswordsLive);
    _senhaConfirmController.addListener(_validatePasswordsLive);
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _senhaConfirmController.dispose();
    super.dispose();
  }

  String? _validateNotEmpty(String? value, String label) {
    if (value == null || value.isEmpty) {
      return 'Informe $label';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe o Email';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'E-mail inválido';
    }
    return null;
  }

  String? _validateSenha(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe a Senha';
    }
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  void _validatePasswordsLive() {
    final pwd = _senhaController.text;
    final confirm = _senhaConfirmController.text;
    String? err;
    if (confirm.isNotEmpty) {
      if (pwd != confirm) {
        err = 'Senhas não coincidem.';
      } else if (pwd.length < 6) {
        err = 'Senha deve ter mínimo 6 caracteres.';
      }
    }
    if (err != _passwordError) {
      setState(() => _passwordError = err);
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    final email = _emailController.text.trim();
    final username = _usuarioController.text.trim();
    final password = _senhaController.text;
    final confirm = _senhaConfirmController.text;
    bool success = false;
    Object? firebaseError;
    if (password.isNotEmpty || confirm.isNotEmpty) {
      if (confirm.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Confirme a nova senha.')));
        setState(() => _loading = false);
        return;
      }
      if (password != confirm) {
        setState(() => _passwordError = 'Senhas não coincidem.');
        setState(() => _loading = false);
        return;
      }
      if (password.length < 6) {
        setState(() => _passwordError = 'Senha deve ter mínimo 6 caracteres.');
        setState(() => _loading = false);
        return;
      }
      setState(() => _passwordError = null);
    }
    try {
      final firebaseReady = await FirebaseAuthService.ensureInitialized();
      if (firebaseReady) {
        final cred = await FirebaseAuthService().register(email, password);
        if (username.isNotEmpty) {
          await cred.user?.updateDisplayName(username);
        }
        success = true;
      }
    } catch (e) {
      firebaseError = e;
    }

    if (!success) {
      final okLocal = await _auth.register(email, username, password);
      success = okLocal;
      if (!okLocal && mounted) {
        final fallbackMessage =
            firebaseError != null
                ? 'Falha no cadastro remoto: $firebaseError'
                : 'E-mail ou usuário já existe.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(fallbackMessage)));
      }
    }
    setState(() => _loading = false);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário cadastrado! Faça login.')),
      );
      widget.onSuccess?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Cadastro', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),
          AppTextField(
            label: 'Nome de Usuário',
            icon: Icons.person,
            controller: _usuarioController,
            validator: (v) => _validateNotEmpty(v, 'o Nome de Usuário'),
          ),
          const SizedBox(height: 10),
          AppTextField(
            label: 'Email',
            icon: Icons.email,
            controller: _emailController,
            validator: _validateEmail,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 10),
          AppTextField(
            label: 'Senha',
            icon: Icons.lock,
            controller: _senhaController,
            obscureText: true,
            validator: _validateSenha,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _senhaConfirmController,
            decoration: InputDecoration(
              labelText: 'Confirmar Senha',
              prefixIcon: const Icon(Icons.lock_outline),
              errorText: _passwordError,
            ),
            obscureText: true,
          ),
          const SizedBox(height: 20),
          Semantics(
            button: true,
            label: 'Enviar cadastro',
            child: AppButton(
              label: _loading ? 'Enviando...' : 'Cadastrar',
              icon: Icons.check,
              onTap: _loading ? () {} : _submit,
            ),
          ),
        ],
      ),
    );
  }
}
