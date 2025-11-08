import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/shared.dart';
import '../components/molecules/app_text_field.dart';
import '../components/atoms/app_button.dart';
import '../services/auth_service.dart';
import '../services/firebase_auth_service.dart';

// Formata entrada para o padrão dd/mm/aaaa automaticamente
class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Mantém apenas dígitos e limita a 8 (ddMMyyyy)
    final raw = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final digits = raw.length > 8 ? raw.substring(0, 8) : raw;

    // Reconstroi com barras após 2 e 4
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      if (i == 1 || i == 3) buffer.write('/');
    }
    final masked = buffer.toString();

    // Calcula a nova posição do cursor com base na quantidade de dígitos
    final selectionRawDigits = _countDigitsBeforeCursor(
      newValue.text,
      newValue.selection.end,
    );
    var cursor = selectionRawDigits;
    if (cursor >= 2) cursor++;
    if (cursor >= 4) cursor++;
    if (cursor > masked.length) cursor = masked.length;
    if (cursor < 0) cursor = 0;

    return TextEditingValue(
      text: masked,
      selection: TextSelection.collapsed(offset: cursor),
    );
  }

  int _countDigitsBeforeCursor(String text, int cursorIndex) {
    if (cursorIndex <= 0) return 0;
    if (cursorIndex > text.length) cursorIndex = text.length;
    final sub = text.substring(0, cursorIndex);
    return RegExp(r'[0-9]').allMatches(sub).length;
  }
}

// Formata entrada de telefone brasileiro: (99) 99999-9999 ou (99) 9999-9999
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final digits = raw.length > 11 ? raw.substring(0, 11) : raw;

    String masked = _mask(digits);

    // Calcular posição do cursor: conta dígitos antes e traduz para posição na máscara
    final selectionRawDigits = _countDigitsBeforeCursor(
      newValue.text,
      newValue.selection.end,
    );
    int cursor = _cursorForMasked(selectionRawDigits, masked);
    if (cursor > masked.length) cursor = masked.length;
    if (cursor < 0) cursor = 0;

    return TextEditingValue(
      text: masked,
      selection: TextSelection.collapsed(offset: cursor),
    );
  }

  String _mask(String digits) {
    final len = digits.length;
    if (len == 0) return '';
    final b = StringBuffer();
    b.write('(');
    for (int i = 0; i < len && i < 2; i++) {
      b.write(digits[i]);
    }
    if (len >= 2) b.write(') ');
    if (len <= 6) {
      // Até 6 => (99) 9 999 (construindo)
      for (int i = 2; i < len; i++) {
        b.write(digits[i]);
      }
    } else if (len <= 10) {
      // 10 dígitos total => (99) 9999-9999
      for (int i = 2; i < 6; i++) {
        b.write(digits[i]);
      }
      b.write('-');
      for (int i = 6; i < len; i++) {
        b.write(digits[i]);
      }
    } else {
      // 11 dígitos total => (99) 99999-9999
      for (int i = 2; i < 7; i++) {
        b.write(digits[i]);
      }
      b.write('-');
      for (int i = 7; i < len; i++) {
        b.write(digits[i]);
      }
    }
    return b.toString();
  }

  int _countDigitsBeforeCursor(String text, int cursorIndex) {
    if (cursorIndex <= 0) return 0;
    if (cursorIndex > text.length) cursorIndex = text.length;
    final sub = text.substring(0, cursorIndex);
    return RegExp(r'[0-9]').allMatches(sub).length;
  }

  int _cursorForMasked(int rawDigitsBefore, String masked) {
    // Avança através da máscara contando dígitos até atingir rawDigitsBefore
    int digitsSeen = 0;
    for (int i = 0; i < masked.length; i++) {
      if (RegExp(r'[0-9]').hasMatch(masked[i])) {
        digitsSeen++;
        if (digitsSeen == rawDigitsBefore) {
          return i + 1; // cursor após esse dígito
        }
      }
    }
    return masked.length;
  }
}

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
  // Instancia FirebaseAuthService de forma lazy dentro do submit para evitar erros em web sem config.
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

  String? _validateDataNascimento(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe a Data de Nascimento';
    }
    final v = value.trim();
    final regex = RegExp(r'^(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[0-2])\/\d{4}$');
    if (!regex.hasMatch(v)) {
      return 'Use o formato dd/mm/aaaa';
    }
    final parts = v.split('/');
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) {
      return 'Data inválida';
    }
    final dt = DateTime(year, month, day);
    if (dt.year != year || dt.month != month || dt.day != day) {
      return 'Data inválida';
    }
    final today = DateTime.now();
    final endOfToday = DateTime(today.year, today.month, today.day, 23, 59, 59);
    if (dt.isAfter(endOfToday)) {
      return 'Data não pode ser no futuro';
    }
    if (year < 1900) {
      return 'Ano inválido';
    }
    return null;
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

  String? _validateCelular(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe o Celular';
    }
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 10 || digits.length > 11) {
      return 'Celular deve ter 10 ou 11 dígitos';
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
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    final email = _emailController.text.trim();
    final password = _senhaController.text;
    final displayName = _nomeController.text.trim();
    bool success = false;
    // Tenta Firebase primeiro se inicializado; se não, fallback local
    try {
      final firebaseReady = await FirebaseAuthService.ensureInitialized();
      if (firebaseReady) {
        final cred = await FirebaseAuthService().register(email, password);
        if (displayName.isNotEmpty) {
          await cred.user?.updateDisplayName(displayName);
        }
        success = true;
      } else {
        final okLocal = await _auth.register(
          email,
          _usuarioController.text.trim(),
          password,
        );
        success = okLocal;
        if (!okLocal && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('E-mail ou usuário já existe.')),
          );
        }
      }
    } catch (e) {
      // Erros de Firebase (ex.: email em uso, provedor desabilitado etc.)
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Falha no cadastro: $e')));
      }
    }
    setState(() => _loading = false);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário cadastrado! Faça login.')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
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
                    initialValue: _sexoSelecionado,
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
                    decoration: const InputDecoration(
                      labelText: 'Data de Nascimento',
                      hintText: 'dd/mm/aaaa',
                      counterText: '',
                    ),
                    keyboardType: TextInputType.datetime,
                    maxLength: 10,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      DateInputFormatter(),
                    ],
                    validator: _validateDataNascimento,
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
                    keyboardType: TextInputType.phone,
                    hintText: '(99) 99999-9999',
                    maxLength: 15,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      PhoneInputFormatter(),
                    ],
                    validator: _validateCelular,
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
