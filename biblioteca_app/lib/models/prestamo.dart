import 'estudiante.dart';
import 'libro.dart';

/// Un préstamo: qué libro, a qué estudiante y en qué fechas.
class Prestamo {
  final Libro libro;
  final Estudiante estudiante;
  final DateTime fechaPrestamo;
  final DateTime fechaMaxima;

  /// Es null mientras el libro no se haya devuelto.
  DateTime? fechaDevolucion;

  Prestamo({
    required this.libro,
    required this.estudiante,
    required this.fechaPrestamo,
    required this.fechaMaxima,
    this.fechaDevolucion,
  });

  bool get activo => fechaDevolucion == null;

  /// Días que faltan para la fecha máxima (negativo si ya venció).
  /// Se comparan solo las fechas, sin las horas.
  int get diasRestantes {
    final hoy = DateTime.now();
    final h = DateTime.utc(hoy.year, hoy.month, hoy.day);
    final v = DateTime.utc(
      fechaMaxima.year,
      fechaMaxima.month,
      fechaMaxima.day,
    );
    return v.difference(h).inDays;
  }

  bool get vencido => activo && diasRestantes < 0;

  /// Vence hoy o en los próximos 2 días (y aún no está vencido).
  bool get porVencer => activo && diasRestantes >= 0 && diasRestantes <= 2;
}
