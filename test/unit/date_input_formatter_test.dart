import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:run/screens/register_page.dart';

void main() {
  group('DateInputFormatter', () {
    test('aplica máscara dd/mm/aaaa corretamente', () {
      final f = DateInputFormatter();
      TextEditingValue v = const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
      v = f.formatEditUpdate(
        v,
        const TextEditingValue(
          text: '1',
          selection: TextSelection.collapsed(offset: 1),
        ),
      );
      expect(v.text, '1');
      v = f.formatEditUpdate(
        v,
        const TextEditingValue(
          text: '12',
          selection: TextSelection.collapsed(offset: 2),
        ),
      );
      expect(v.text, '12/');
      v = f.formatEditUpdate(
        v,
        const TextEditingValue(
          text: '120',
          selection: TextSelection.collapsed(offset: 3),
        ),
      );
      expect(v.text, '12/0');
      v = f.formatEditUpdate(
        v,
        const TextEditingValue(
          text: '1201',
          selection: TextSelection.collapsed(offset: 4),
        ),
      );
      expect(v.text, '12/01/');
      v = f.formatEditUpdate(
        v,
        const TextEditingValue(
          text: '12012025',
          selection: TextSelection.collapsed(offset: 8),
        ),
      );
      expect(v.text, '12/01/2025');
      // Limite de 10 caracteres com barras
      v = f.formatEditUpdate(
        v,
        const TextEditingValue(
          text: '1201202501',
          selection: TextSelection.collapsed(offset: 10),
        ),
      );
      expect(v.text, '12/01/2025');
    });
  });
}
