import 'package:flutter/material.dart';
import '../../components/molecules/app_text_field.dart';
import '../../components/atoms/app_button.dart';

class LoginForm extends StatefulWidget {
  final Future<bool> Function(String email, String password) onSubmit;
  final VoidCallback onForgot;
  final VoidCallback onRegister;

  const LoginForm({
    super.key,
    required this.onSubmit,
    required this.onForgot,
    required this.onRegister,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Informe o e-mail';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value)) return 'E-mail inválido';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Informe a senha';
    if (value.length < 6) return 'A senha deve ter pelo menos 6 caracteres';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final ok = await widget.onSubmit(
      _emailController.text.trim(),
      _passwordController.text,
    );
    setState(() => _loading = false);
    if (!ok && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Credenciais inválidas.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            label: 'Email',
            icon: Icons.email,
            controller: _emailController,
            validator: _validateEmail,
            semanticLabel: 'Campo de email',
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Senha',
            icon: Icons.lock,
            controller: _passwordController,
            validator: _validatePassword,
            semanticLabel: 'Campo de senha',
            obscureText: true,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: _loading ? null : widget.onForgot,
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Text(
                  'Esqueci minha senha',
                  style: TextStyle(
                    color: Color(0xFF4A6D7C),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: _loading ? 'Entrando...' : 'Entrar',
                  icon: Icons.login,
                  onTap: _loading ? () {} : _submit,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  label: 'Cadastrar',
                  icon: Icons.app_registration,
                  color: Theme.of(context).colorScheme.secondary,
                  onTap: _loading ? () {} : widget.onRegister,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
