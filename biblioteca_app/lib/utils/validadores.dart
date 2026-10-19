/// Validadores de campos de formulario, reutilizables y fáciles de probar.
///
/// Cada uno recibe el texto escrito y devuelve un mensaje de error, o null
/// si el valor es válido (así lo espera el parámetro `validator` de
/// TextFormField).
class Validadores {
  Validadores._();

  /// El campo no puede estar vacío.
  static String? requerido(String? valor, String mensaje) {
    if (valor == null || valor.trim().isEmpty) return mensaje;
    return null;
  }

  /// Mínimo de caracteres (sin contar espacios de los extremos).
  static String? longitudMinima(String? valor, int minimo, String mensaje) {
    if (valor == null || valor.trim().length < minimo) return mensaje;
    return null;
  }

  /// Número entero mayor o igual a [minimo].
  static String? enteroMinimo(String? valor, int minimo) {
    final n = int.tryParse((valor ?? '').trim());
    if (n == null) return 'Escribe un número';
    if (n < minimo) return 'Debe haber al menos $minimo';
    return null;
  }

  /// Correo con formato básico: texto@dominio.ext
  static String? correo(String? valor) {
    final texto = (valor ?? '').trim();
    if (texto.isEmpty) return 'Escribe el correo';
    final formato = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!formato.hasMatch(texto)) return 'Escribe un correo válido';
    return null;
  }
}
