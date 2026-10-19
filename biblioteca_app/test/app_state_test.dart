import 'package:biblioteca_app/models/libro.dart';
import 'package:biblioteca_app/state/app_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('arranca con datos de ejemplo e inventario coherente', () {
    final estado = AppState();
    expect(estado.libros.length, 3);
    expect(estado.estudiantes.length, 3);
    // El Principito tiene 1 ejemplar y está prestado.
    final principito =
        estado.libros.firstWhere((l) => l.titulo == 'El Principito');
    expect(principito.disponible, isFalse);
  });

  test('agregar un libro avisa a los oyentes', () {
    final estado = AppState();
    var avisos = 0;
    estado.addListener(() => avisos++);

    estado.agregarLibro(Libro(
      codigo: 'LIB-010',
      titulo: 'Nuevo',
      autor: 'Autor',
      ejemplaresTotal: 2,
    ));

    expect(estado.libros.length, 4);
    expect(avisos, 1);
  });

  test('no se elimina un libro con préstamo sin devolver', () {
    final estado = AppState();
    final principito =
        estado.libros.firstWhere((l) => l.titulo == 'El Principito');

    expect(estado.eliminarLibro(principito), isNotNull);
    expect(estado.libros.contains(principito), isTrue);
  });

  test('devolver un préstamo libera el ejemplar', () {
    final estado = AppState();
    final prestamo = estado.prestamosActivos
        .firstWhere((p) => p.libro.titulo == 'El Principito');

    estado.devolver(prestamo);

    expect(prestamo.activo, isFalse);
    expect(prestamo.libro.disponible, isTrue);
  });

  test('registrar un préstamo descuenta un ejemplar', () {
    final estado = AppState();
    final libro =
        estado.libros.firstWhere((l) => l.titulo == 'Cien años de soledad');
    final antes = libro.ejemplaresDisponibles;

    estado.registrarPrestamo(
      libro,
      estado.estudiantes.first,
      DateTime.now().add(const Duration(days: 7)),
    );

    expect(libro.ejemplaresDisponibles, antes - 1);
  });
}
