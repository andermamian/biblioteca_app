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
import '../widgets/panel_datos.dart';
import '../widgets/tarjeta.dart';

/// Préstamos activos: registrar un préstamo nuevo (RF03) y registrar la
/// devolución (RF04), que vuelve a dejar disponible el libro.
class PrestamosScreen extends StatefulWidget {
  const PrestamosScreen({super.key});

  @override
  State<PrestamosScreen> createState() => _PrestamosScreenState();
}

class _PrestamosScreenState extends State<PrestamosScreen> {
  void _mensaje(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _nuevoPrestamo() async {
    final prestamo = await showDialog<Prestamo>(
      context: context,
      builder: (_) => const _FormularioPrestamo(),
    );
    if (prestamo == null || !mounted) return;

    EstadoApp.leer(context).registrarPrestamo(
      prestamo.libro,
      prestamo.estudiante,
      prestamo.fechaMaxima,
    );
    _mensaje('Préstamo registrado');
  }

  void _devolver(Prestamo prestamo) {
    EstadoApp.leer(context).devolver(prestamo);
    _mensaje('Libro devuelto: ${prestamo.libro.titulo}');
  }

  @override
  Widget build(BuildContext context) {
    // Observa el estado: si cambia, esta pantalla se redibuja.
    final estado = EstadoApp.of(context);
    final activos = estado.prestamosActivos;

    return Scaffold(
      appBar: BarraDegradada(
        titulo: 'Préstamos',
        icono: Icons.swap_horiz,
        acciones: [
          // Vuelve a dibujar la lista con los datos actuales.
          IconButton(
            tooltip: 'Actualizar',
            onPressed: estado.actualizar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _nuevoPrestamo,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo préstamo'),
      ),
      body: ContenidoCentrado(
        child: activos.isEmpty
          ? const Center(child: Text('No hay préstamos activos'))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: activos.length,
              itemBuilder: (context, i) {
                final p = activos[i];
                return Tarjeta(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CajaIcono(icono: Icons.menu_book),
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
                                Row(
                                  children: [
                                    const Icon(Icons.person,
                                        size: 16, color: AppColores.iconoSuave),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        p.estudiante.nombre,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: AppColores.textoSuave,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          EstadoChip.dePrestamo(p),
                        ],
                      ),
                      const SizedBox(height: 12),
                      PanelDatos(
                        datos: [
                          DatoPanel(
                            icono: Icons.calendar_today,
                            etiqueta: 'Prestado',
                            valor: formatoFecha(p.fechaPrestamo),
                          ),
                          DatoPanel(
                            icono: Icons.calendar_today,
                            etiqueta: 'Fecha máxima',
                            valor: formatoFecha(p.fechaMaxima),
                            // La fecha se pinta de rojo si ya venció.
                            colorValor: p.vencido ? AppColores.rojo : null,
                          ),
                          DatoPanel(
                            icono: Icons.sell,
                            etiqueta: 'Estudiante',
                            valor: p.estudiante.codigo,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => _devolver(p),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 52),
                          ),
                          icon: const Icon(Icons.keyboard_return),
                          label: const Text('Registrar devolución'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      ),
    );
  }
}

/// Formulario (en un AlertDialog) para registrar un préstamo: elegir el
/// libro, el estudiante y la fecha máxima de devolución.
class _FormularioPrestamo extends StatefulWidget {
  const _FormularioPrestamo();

  @override
  State<_FormularioPrestamo> createState() => _FormularioPrestamoState();
}

class _FormularioPrestamoState extends State<_FormularioPrestamo> {
  final _formKey = GlobalKey<FormState>();

  Libro? _libro;
  Estudiante? _estudiante;
  DateTime _fechaMaxima = DateTime.now().add(const Duration(days: 8));

  /// Abre el calendario para elegir la fecha máxima de devolución.
  Future<void> _elegirFecha() async {
    final hoy = DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fechaMaxima,
      firstDate: hoy,
      lastDate: hoy.add(const Duration(days: 30)),
    );
    if (elegida != null) setState(() => _fechaMaxima = elegida);
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      Prestamo(
        libro: _libro!,
        estudiante: _estudiante!,
        fechaPrestamo: DateTime.now(),
        fechaMaxima: _fechaMaxima,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Solo se pueden prestar libros con ejemplares disponibles.
    final estado = EstadoApp.leer(context);
    final disponibles = estado.libros.where((l) => l.disponible).toList();

    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: const Row(
        children: [
          Icon(Icons.swap_horiz, color: AppColores.primario),
          SizedBox(width: 12),
          Text(
            'Nuevo préstamo',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColores.texto,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Libro>(
                isExpanded: true,
                decoration: decoracionCampo('Libro', Icons.menu_book),
                items: [
                  for (final l in disponibles)
                    DropdownMenuItem(
                      value: l,
                      child: Text(l.titulo, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (valor) => _libro = valor,
                validator: (v) => v == null ? 'Elige el libro' : null,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<Estudiante>(
                isExpanded: true,
                decoration: decoracionCampo('Estudiante', Icons.person),
                items: [
                  for (final e in estado.estudiantes)
                    DropdownMenuItem(
                      value: e,
                      child: Text(e.nombre, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (valor) => _estudiante = valor,
                validator: (v) => v == null ? 'Elige el estudiante' : null,
              ),
              const SizedBox(height: 16),
              // Campo de solo lectura que abre el calendario al tocarlo.
              InkWell(
                onTap: _elegirFecha,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha máxima de devolución',
                    prefixIcon: Icon(Icons.calendar_month),
                  ),
                  child: Text(formatoFecha(_fechaMaxima)),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: _guardar,
          icon: const Icon(Icons.check),
          label: const Text('Registrar'),
        ),
      ],
    );
  }
}
