import 'package:flutter/material.dart';

import '../models/estudiante.dart';
import '../models/libro.dart';
import '../models/prestamo.dart';
import '../state/app_state.dart';
import '../theme/app_tema.dart';
import '../utils/formato.dart';
import '../widgets/barra_degradada.dart';
import '../widgets/caja_icono.dart';
import '../widgets/contenido_centrado.dart';
import '../widgets/estado_chip.dart';
import '../widgets/tarjeta.dart';

/// Historial de préstamos (RF05): se consulta por estudiante o por libro.
class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  bool _porEstudiante = true; // true = por estudiante, false = por libro

  // Selección del usuario; si es null se usa el primer elemento de la lista.
  Estudiante? _estudiante;
  Libro? _libro;

  @override
  Widget build(BuildContext context) {
    final estado = EstadoApp.of(context);

    // Si el elemento elegido ya no existe (se eliminó), se vuelve al primero.
    final estudiante = estado.estudiantes.contains(_estudiante)
        ? _estudiante
        : (estado.estudiantes.length > 1
            ? estado.estudiantes[1] // por defecto, Luis Ramírez (tiene 2 préstamos)
            : (estado.estudiantes.isEmpty ? null : estado.estudiantes.first));
    final libro = estado.libros.contains(_libro)
        ? _libro
        : (estado.libros.isEmpty ? null : estado.libros.first);

    // Préstamos que corresponden a la consulta elegida.
    final resultados = estado.prestamos.where((p) {
      return _porEstudiante ? p.estudiante == estudiante : p.libro == libro;
    }).toList();

    return _construir(context, estado, estudiante, libro, resultados);
  }

  /// Borde redondeado de la lista desplegable.
  InputDecoration _decoracion(String etiqueta) {
    return InputDecoration(
      labelText: etiqueta,
      prefixIcon: const Icon(Icons.search),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColores.textoSuave),
      ),
    );
  }

  Widget _construir(
    BuildContext context,
    AppState estado,
    Estudiante? estudiante,
    Libro? libro,
    List<Prestamo> resultados,
  ) {
    return Scaffold(
      appBar: const BarraDegradada(titulo: 'Historial de préstamos'),
      body: ContenidoCentrado(
        child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tarjeta de consulta: tipo de búsqueda + lista desplegable.
          Tarjeta(
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<bool>(
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: const Color(0xFFE0E3F7),
                      selectedForegroundColor: AppColores.primario,
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    segments: const [
                      ButtonSegment(
                        value: true,
                        label: Text('Por estudiante'),
                        icon: Icon(Icons.person),
                      ),
                      ButtonSegment(
                        value: false,
                        label: Text('Por libro'),
                        icon: Icon(Icons.menu_book),
                      ),
                    ],
                    selected: {_porEstudiante},
                    onSelectionChanged: (seleccion) =>
                        setState(() => _porEstudiante = seleccion.first),
                  ),
                ),
                const SizedBox(height: 16),
                // Lista desplegable: estudiantes o libros según la consulta.
                if (_porEstudiante)
                  InputDecorator(
                    isEmpty: estudiante == null,
                    decoration: _decoracion('Selecciona un estudiante'),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Estudiante>(
                        isExpanded: true,
                        value: estudiante,
                        borderRadius: BorderRadius.circular(16),
                        items: [
                          for (final e in estado.estudiantes)
                            DropdownMenuItem(value: e, child: Text(e.nombre)),
                        ],
                        onChanged: (valor) => setState(() => _estudiante = valor),
                      ),
                    ),
                  )
                else
                  InputDecorator(
                    isEmpty: libro == null,
                    decoration: _decoracion('Selecciona un libro'),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Libro>(
                        isExpanded: true,
                        value: libro,
                        borderRadius: BorderRadius.circular(16),
                        items: [
                          for (final l in estado.libros)
                            DropdownMenuItem(value: l, child: Text(l.titulo)),
                        ],
                        onChanged: (valor) => setState(() => _libro = valor),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (resultados.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('Sin préstamos registrados')),
            ),
          for (final p in resultados) _TarjetaHistorial(prestamo: p),
        ],
      ),
      ),
    );
  }
}

/// Tarjeta de un préstamo del historial: libro, estudiante, estado y fechas.
class _TarjetaHistorial extends StatelessWidget {
  final Prestamo prestamo;
  const _TarjetaHistorial({required this.prestamo});

  @override
  Widget build(BuildContext context) {
    final p = prestamo;

    return Tarjeta(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CajaIcono(icono: Icons.history, circular: true),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.libro.titulo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColores.texto,
                      ),
                    ),
                    Text(
                      p.estudiante.nombre,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColores.textoSuave,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              EstadoChip.dePrestamo(p),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColores.panel,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _FilaFecha(
                  icono: Icons.calendar_today,
                  etiqueta: 'Prestado:',
                  valor: formatoFecha(p.fechaPrestamo),
                ),
                _FilaFecha(
                  icono: Icons.calendar_today,
                  etiqueta: 'Máximo:',
                  valor: formatoFecha(p.fechaMaxima),
                ),
                _FilaFecha(
                  icono: Icons.check_circle,
                  etiqueta: 'Devuelto:',
                  valor: p.fechaDevolucion == null
                      ? '–'
                      : formatoFecha(p.fechaDevolucion!),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Fila "icono + etiqueta + fecha en negrita".
class _FilaFecha extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;
  const _FilaFecha({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icono, size: 22, color: AppColores.iconoSuave),
          const SizedBox(width: 12),
          Text(
            etiqueta,
            style: const TextStyle(fontSize: 16, color: AppColores.textoSuave),
          ),
          const SizedBox(width: 8),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColores.texto,
            ),
          ),
        ],
      ),
    );
  }
}
