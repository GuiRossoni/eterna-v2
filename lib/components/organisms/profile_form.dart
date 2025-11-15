import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Handles profile updates (display name + password change) in one place.
class ProfileForm extends StatefulWidget {
  const ProfileForm({super.key});

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  bool _saving = false;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.displayName != null) {
      _nameController.text = user.displayName!;
    }
    _passwordController.addListener(_validatePasswordsLive);
    _passwordConfirmController.addListener(_validatePasswordsLive);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final trimmedName = _nameController.text.trim();
        if (trimmedName.isNotEmpty) {
          await user.updateDisplayName(trimmedName);
        }
        final newPwd = _passwordController.text;
        final confirmPwd = _passwordConfirmController.text;
        if (newPwd.isNotEmpty || confirmPwd.isNotEmpty) {
          if (newPwd.isNotEmpty && confirmPwd.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Confirme a nova senha.')),
            );
            setState(() => _saving = false);
            return;
          }
          if (newPwd != confirmPwd) {
            setState(() => _passwordError = 'Senhas não coincidem.');
            setState(() => _saving = false);
            return;
          }
          if (newPwd.length < 6) {
            setState(
              () => _passwordError = 'Senha deve ter mínimo 6 caracteres.',
            );
            setState(() => _saving = false);
            return;
          }
          setState(() => _passwordError = null);
          await user.updatePassword(newPwd);
        }
        await user.reload();
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Perfil atualizado.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao atualizar: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _validatePasswordsLive() {
    final newPwd = _passwordController.text;
    final confirmPwd = _passwordConfirmController.text;
    String? err;
    if (confirmPwd.isNotEmpty) {
      if (newPwd != confirmPwd) {
        err = 'Senhas não coincidem.';
      } else if (newPwd.length < 6) {
        err = 'Senha deve ter mínimo 6 caracteres.';
      }
    }
    if (err != _passwordError) {
      setState(() => _passwordError = err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Usuário',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(
            labelText: 'Nova Senha',
            prefixIcon: Icon(Icons.lock_outline),
            helperText: 'Mínimo 6 caracteres',
          ),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordConfirmController,
          decoration: InputDecoration(
            labelText: 'Confirmar Senha',
            prefixIcon: const Icon(Icons.lock_outline),
            errorText: _passwordError,
          ),
          obscureText: true,
        ),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.save),
            label: Text(_saving ? 'Salvando...' : 'Salvar'),
          ),
        ),
      ],
    );
  }
}
