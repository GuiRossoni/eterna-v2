import 'package:flutter/material.dart';
import '../widgets/shared.dart';
import '../components/molecules/app_text_field.dart';
import '../components/atoms/app_button.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _usuarioController = TextEditingController();
  String? _sexoSelecionado;
  final _dataNascimentoController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _emailController = TextEditingController();
  final _celularController = TextEditingController();
  final _senhaController = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _usuarioController.dispose();
    _dataNascimentoController.dispose();
    _enderecoController.dispose();
    _emailController.dispose();
    _celularController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _openDatePicker() async {
    try {
      FocusScope.of(context).unfocus();
      final now = DateTime.now();
      final tenYearsAgo = DateTime(now.year - 10, now.month, now.day);
      final initial =
          tenYearsAgo.isBefore(DateTime(1900)) ? DateTime(1900) : tenYearsAgo;
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(1900),
        lastDate: now,
      );
      if (pickedDate != null) {
        _dataNascimentoController.text =
            "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir o seletor de data.'),
        ),
      );
    }
  }

  String? _validateEndereco(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe o Endereço';
    }
    final enderecoRegex = RegExp(r'^[a-zA-Z0-9\s,.-]+$');
    if (!enderecoRegex.hasMatch(value)) {
      return 'Endereço não pode conter caracteres especiais';
    }
    return null;
  }

  String? _validateCelularNumeros(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe o Celular';
    }
    final celularRegex = RegExp(r'^\d{8,15}$');
    if (!celularRegex.hasMatch(value)) {
      return 'Celular deve conter apenas números';
    }
    return null;
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final ok = await _auth.register(
      _emailController.text.trim(),
      _usuarioController.text.trim(),
      _senhaController.text,
    );
    setState(() => _loading = false);
    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-mail ou usuário já existe.')),
      );
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuário cadastrado! Faça login.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          child: GlassPanel(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Cadastro",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: 'Nome Completo',
                    icon: Icons.badge,
                    controller: _nomeController,
                    validator: (v) => _validateNotEmpty(v, 'o Nome Completo'),
                  ),
                  const SizedBox(height: 10),
                  AppTextField(
                    label: 'Nome de Usuário',
                    icon: Icons.person,
                    controller: _usuarioController,
                    validator: (v) => _validateNotEmpty(v, 'o Nome de Usuário'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _sexoSelecionado,
                    decoration: const InputDecoration(labelText: 'Sexo'),
                    items: const [
                      DropdownMenuItem(
                        value: 'Feminino',
                        child: Text('Feminino'),
                      ),
                      DropdownMenuItem(
                        value: 'Masculino',
                        child: Text('Masculino'),
                      ),
                      DropdownMenuItem(
                        value: 'Não informar',
                        child: Text('Não informar'),
                      ),
                    ],
                    onChanged:
                        (value) => setState(() => _sexoSelecionado = value),
                    validator:
                        (v) =>
                            (v == null || v.isEmpty) ? 'Informe o Sexo' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _dataNascimentoController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Data de Nascimento',
                    ),
                    onTap: _openDatePicker,
                    validator:
                        (v) => _validateNotEmpty(v, 'a Data de Nascimento'),
                  ),
                  const SizedBox(height: 10),
                  AppTextField(
                    label: 'Endereço',
                    icon: Icons.home,
                    controller: _enderecoController,
                    validator: _validateEndereco,
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
                    label: 'Celular',
                    icon: Icons.phone,
                    controller: _celularController,
                    keyboardType: TextInputType.number,
                    validator: _validateCelularNumeros,
                  ),
                  const SizedBox(height: 10),
                  AppTextField(
                    label: 'Senha',
                    icon: Icons.lock,
                    controller: _senhaController,
                    obscureText: true,
                    validator: _validateSenha,
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
            ),
          ),
        ),
      ),
    );
  }
}
