import 'package:flutter/material.dart';

/// Paleta de la aplicación. Todas las pantallas usan estos colores para que
/// el diseño sea coherente (el mismo índigo, los mismos estados).
class AppColores {
  AppColores._();

  // Marca (índigo).
  static const Color primario = Color(0xFF3949AB);
  static const Color boton = Color(0xFF34409E);
  static const Color degradadoInicio = Color(0xFF303F9F);
  static const Color degradadoFin = Color(0xFF5C6BC0);

  // Fondos.
  static const Color fondo = Color(0xFFF3F4FA);
  static const Color panel = Color(0xFFF3F4FA);
  static const Color cajaIcono = Color(0xFFE8EAF6);
  static const Color borde = Color(0xFFDDE0F0);

  // Textos e iconos.
  static const Color texto = Color(0xFF1B1E3B);
  static const Color textoSuave = Color(0xFF5C6078);
  static const Color iconoSuave = Color(0xFF8C90A8);

  // Estados.
  static const Color verde = Color(0xFF2E7D32);
  static const Color azul = Color(0xFF1565C0);
  static const Color ambar = Color(0xFF9A5B00);
  static const Color rojo = Color(0xFFB3261E);

  /// Degradado de la barra superior y de los encabezados.
  static const LinearGradient degradado = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [degradadoInicio, degradadoFin],
  );
}

/// Tema general (Material 3): colores, botones y botón flotante.
ThemeData crearTema() {
  final esquema = ColorScheme.fromSeed(seedColor: AppColores.primario)
      .copyWith(primary: AppColores.primario);

  return ThemeData(
    useMaterial3: true,
    colorScheme: esquema,
    scaffoldBackgroundColor: AppColores.fondo,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFE0E3F7),
      foregroundColor: AppColores.primario,
      extendedTextStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
    ),
    // Botones rellenos con forma de píldora.
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColores.boton,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 48),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColores.primario,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}

/// Decoración común de los campos de los formularios: etiqueta + icono.
InputDecoration decoracionCampo(String etiqueta, IconData icono) {
  return InputDecoration(
    labelText: etiqueta,
    prefixIcon: Icon(icono),
  );
}
