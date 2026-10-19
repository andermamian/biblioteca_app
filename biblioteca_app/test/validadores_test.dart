import 'package:biblioteca_app/utils/validadores.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validadores', () {
    test('requerido rechaza vacío y espacios', () {
      expect(Validadores.requerido('', 'Falta'), 'Falta');
      expect(Validadores.requerido('   ', 'Falta'), 'Falta');
      expect(Validadores.requerido(null, 'Falta'), 'Falta');
      expect(Validadores.requerido('Hola', 'Falta'), isNull);
    });

    test('longitudMinima exige un mínimo de caracteres', () {
      expect(Validadores.longitudMinima('ab', 3, 'Corto'), 'Corto');
      expect(Validadores.longitudMinima('abc', 3, 'Corto'), isNull);
    });

    test('enteroMinimo acepta números desde el mínimo', () {
      expect(Validadores.enteroMinimo('', 1), isNotNull);
      expect(Validadores.enteroMinimo('abc', 1), isNotNull);
      expect(Validadores.enteroMinimo('0', 1), isNotNull);
      expect(Validadores.enteroMinimo('3', 1), isNull);
    });

    test('correo valida el formato básico', () {
      expect(Validadores.correo(''), isNotNull);
      expect(Validadores.correo('ana'), isNotNull);
      expect(Validadores.correo('ana@correo'), isNotNull);
      expect(Validadores.correo('ana@correo.com'), isNull);
    });
  });
}
