import '../models/estudiante.dart';
import '../models/libro.dart';
import '../models/prestamo.dart';

/// Datos de ejemplo con los que arranca la aplicación.
///
/// No hay base de datos: [AppState] crea sus listas a partir de estas
/// funciones al abrir la app, y los cambios se pierden al cerrarla.
class DatosEjemplo {
  DatosEjemplo._();

  static List<Libro> libros() => [
        Libro(
          codigo: 'LIB-001',
          titulo: 'Cien años de soledad',
          autor: 'Gabriel García Márquez',
          categoria: 'Literatura',
          ejemplaresTotal: 3,
        ),
        Libro(
          codigo: 'LIB-002',
          titulo: 'Clean Code',
          autor: 'Robert C. Martin',
          categoria: 'Tecnología',
          ejemplaresTotal: 2,
        ),
        Libro(
          codigo: 'LIB-003',
          titulo: 'El Principito',
          autor: 'Antoine de Saint-Exupéry',
          categoria: 'Infantil',
          ejemplaresTotal: 1,
        ),
      ];

  static List<Estudiante> estudiantes() => [
        Estudiante(
          codigo: 'EST-001',
          nombre: 'Ana Torres',
          correo: 'ana.torres@correo.com',
        ),
        Estudiante(
          codigo: 'EST-002',
          nombre: 'Luis Ramírez',
          correo: 'luis.ramirez@correo.com',
        ),
        Estudiante(
          codigo: 'EST-003',
          nombre: 'María Fernanda Peña',
          correo: 'maria.pena@correo.com',
        ),
      ];

  /// Las fechas se calculan a partir de hoy para que siempre haya un
  /// préstamo vencido, uno por vencer y uno ya devuelto.
  static List<Prestamo> prestamos(
    List<Libro> libros,
    List<Estudiante> estudiantes,
  ) {
    final hoy = DateTime.now();
    DateTime dia(int desdeHoy) => hoy.add(Duration(days: desdeHoy));

    return [
      // El Principito está prestado a Luis y vence en 2 días.
      Prestamo(
        libro: libros[2],
        estudiante: estudiantes[1],
        fechaPrestamo: dia(-5),
        fechaMaxima: dia(2),
      ),
      // Clean Code está vencido hace 3 días (1 de sus 2 ejemplares).
      Prestamo(
        libro: libros[1],
        estudiante: estudiantes[0],
        fechaPrestamo: dia(-10),
        fechaMaxima: dia(-3),
      ),
      // Préstamo ya devuelto: solo aparece en el historial.
      Prestamo(
        libro: libros[0],
        estudiante: estudiantes[1],
        fechaPrestamo: dia(-22),
        fechaMaxima: dia(-15),
        fechaDevolucion: dia(-16),
      ),
    ];
  }
}
