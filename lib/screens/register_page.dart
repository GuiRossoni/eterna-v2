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
  final _usuarioController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _senhaConfirmController = TextEditingController();
  final _auth = AuthService();
  // Instancia FirebaseAuthService de forma lazy dentro do submit para evitar erros em web sem config.
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
    // Tenta Firebase primeiro se inicializado; se não, fallback local
    try {
      final firebaseReady = await FirebaseAuthService.ensureInitialized();
      if (firebaseReady) {
        final cred = await FirebaseAuthService().register(email, password);
        if (username.isNotEmpty) {
          await cred.user?.updateDisplayName(username);
        }
        success = true;
      } else {
        final okLocal = await _auth.register(email, username, password);
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
            ),
          ),
        ),
      ),
    );
  }
}
