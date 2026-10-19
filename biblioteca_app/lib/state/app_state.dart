import 'dart:collection';

import 'package:flutter/material.dart';

import '../data/datos_ejemplo.dart';
import '../models/estudiante.dart';
import '../models/libro.dart';
import '../models/prestamo.dart';

/// Estado de la aplicación: guarda las listas y las reglas para cambiarlas.
///
/// Extiende ChangeNotifier: cada vez que algo cambia llama a
/// notifyListeners() y todas las pantallas que lo observan se redibujan solas.
/// Así los datos están en un solo lugar y las pantallas no se pasan datos
/// entre sí.
class AppState extends ChangeNotifier {
  final List<Libro> _libros = DatosEjemplo.libros();
  final List<Estudiante> _estudiantes = DatosEjemplo.estudiantes();
  late final List<Prestamo> _prestamos =
      DatosEjemplo.prestamos(_libros, _estudiantes);

  AppState() {
    _sincronizarInventario();
  }

  // Las pantallas solo pueden leer las listas; para cambiarlas usan los
  // métodos de abajo (así siempre se avisa a las pantallas).
  UnmodifiableListView<Libro> get libros => UnmodifiableListView(_libros);
  UnmodifiableListView<Estudiante> get estudiantes =>
      UnmodifiableListView(_estudiantes);
  UnmodifiableListView<Prestamo> get prestamos =>
      UnmodifiableListView(_prestamos);

  /// Préstamos que todavía no se han devuelto.
  List<Prestamo> get prestamosActivos =>
      _prestamos.where((p) => p.activo).toList();

  /// Préstamos vencidos o por vencer, del más urgente al menos urgente.
  List<Prestamo> get alertas => _prestamos
      .where((p) => p.vencido || p.porVencer)
      .toList()
    ..sort((a, b) => a.fechaMaxima.compareTo(b.fechaMaxima));

  /// Ajusta los ejemplares disponibles según los préstamos activos.
  void _sincronizarInventario() {
    for (final libro in _libros) {
      final prestados =
          _prestamos.where((p) => p.activo && p.libro == libro).length;
      libro.ejemplaresDisponibles =
          (libro.ejemplaresTotal - prestados).clamp(0, libro.ejemplaresTotal);
    }
  }

  // ---- Libros ----

  bool codigoLibroRepetido(String codigo, {Libro? ignorar}) =>
      _libros.any((l) => l != ignorar && l.codigo == codigo.toUpperCase());

  void agregarLibro(Libro libro) {
    _libros.add(libro);
    notifyListeners();
  }

  void actualizarLibro(Libro original, Libro nuevo) {
    original.actualizarDesde(nuevo);
    notifyListeners();
  }

  /// Motivo por el que un libro no se puede eliminar, o null si se puede.
  String? motivoNoEliminarLibro(Libro libro) =>
      _prestamos.any((p) => p.activo && p.libro == libro)
          ? 'No se puede eliminar: tiene préstamos sin devolver'
          : null;

  /// Elimina el libro. Devuelve el mensaje de error si no se pudo.
  String? eliminarLibro(Libro libro) {
    final motivo = motivoNoEliminarLibro(libro);
    if (motivo != null) return motivo;
    _libros.remove(libro);
    notifyListeners();
    return null;
  }

  // ---- Estudiantes ----

  bool codigoEstudianteRepetido(String codigo, {Estudiante? ignorar}) =>
      _estudiantes
          .any((e) => e != ignorar && e.codigo == codigo.toUpperCase());

  void agregarEstudiante(Estudiante estudiante) {
    _estudiantes.add(estudiante);
    notifyListeners();
  }

  void actualizarEstudiante(Estudiante original, Estudiante nuevo) {
    original.codigo = nuevo.codigo;
    original.nombre = nuevo.nombre;
    original.correo = nuevo.correo;
    notifyListeners();
  }

  /// Motivo por el que un estudiante no se puede eliminar, o null si se puede.
  String? motivoNoEliminarEstudiante(Estudiante estudiante) =>
      _prestamos.any((p) => p.estudiante == estudiante)
          ? 'No se puede eliminar: tiene préstamos registrados'
          : null;

  /// Elimina el estudiante. Devuelve el mensaje de error si no se pudo.
  String? eliminarEstudiante(Estudiante estudiante) {
    final motivo = motivoNoEliminarEstudiante(estudiante);
    if (motivo != null) return motivo;
    _estudiantes.remove(estudiante);
    notifyListeners();
    return null;
  }

  // ---- Préstamos ----

  void registrarPrestamo(
    Libro libro,
    Estudiante estudiante,
    DateTime fechaMaxima,
  ) {
    _prestamos.add(Prestamo(
      libro: libro,
      estudiante: estudiante,
      fechaPrestamo: DateTime.now(),
      fechaMaxima: fechaMaxima,
    ));
    libro.ejemplaresDisponibles--; // sale un ejemplar
    notifyListeners();
  }

  void devolver(Prestamo prestamo) {
    prestamo.fechaDevolucion = DateTime.now();
    prestamo.libro.ejemplaresDisponibles++; // el ejemplar vuelve
    notifyListeners();
  }

  /// Vuelve a avisar a las pantallas (botón "actualizar"): útil porque
  /// "vencido" y "por vencer" dependen de la fecha de hoy.
  void actualizar() => notifyListeners();
}

/// Entrega el [AppState] a todas las pantallas que están debajo de él.
///
/// Es un InheritedNotifier: las pantallas que usan [EstadoApp.of] se
/// redibujan automáticamente cuando el estado avisa un cambio.
class EstadoApp extends InheritedNotifier<AppState> {
  const EstadoApp({
    super.key,
    required AppState estado,
    required super.child,
  }) : super(notifier: estado);

  /// Para usar dentro de build(): la pantalla se redibuja si hay cambios.
  static AppState of(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<EstadoApp>();
    assert(inherited != null, 'Falta EstadoApp sobre este widget');
    return inherited!.notifier!;
  }

  /// Para usar en botones y formularios: lee el estado sin suscribirse.
  static AppState leer(BuildContext context) {
    final inherited =
        context.getInheritedWidgetOfExactType<EstadoApp>();
    assert(inherited != null, 'Falta EstadoApp sobre este widget');
    return inherited!.notifier!;
  }
}
