import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:run/screens/register_page.dart';

void main() {
  group('PhoneInputFormatter', () {
    test('formata 10 dígitos como (99) 9999-9999', () {
      final f = PhoneInputFormatter();
      TextEditingValue v = const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
      const digits = '1198765432';
      for (int i = 0; i < digits.length; i++) {
        v = f.formatEditUpdate(
          v,
          TextEditingValue(
            text: v.text + digits[i],
            selection: TextSelection.collapsed(offset: v.text.length + 1),
          ),
        );
      }
      expect(v.text, '(11) 9876-5432');
    });

    test('formata 11 dígitos como (99) 99999-9999', () {
      final f = PhoneInputFormatter();
      TextEditingValue v = const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
      const digits = '11998765432';
      for (int i = 0; i < digits.length; i++) {
        v = f.formatEditUpdate(
          v,
          TextEditingValue(
            text: v.text + digits[i],
            selection: TextSelection.collapsed(offset: v.text.length + 1),
          ),
        );
      }
      expect(v.text, '(11) 99876-5432');
    });
  });
}
