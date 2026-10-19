import 'package:flutter/material.dart';

import '../models/prestamo.dart';
import '../state/app_state.dart';
import '../theme/app_tema.dart';
import '../utils/formato.dart';
import '../widgets/barra_degradada.dart';
import '../widgets/caja_icono.dart';
import '../widgets/contenido_centrado.dart';
import '../widgets/estado_chip.dart';
import '../widgets/tarjeta.dart';

/// Notificaciones en pantalla (RF06): préstamos vencidos o próximos a vencer.
///
/// Son avisos dentro de la app, no notificaciones del sistema operativo.
/// No guarda nada propio: todo lo que muestra sale de [AppState].
class NotificacionesScreen extends StatelessWidget {
  const NotificacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Observa el estado: si cambia, esta pantalla se redibuja.
    final estado = EstadoApp.of(context);

    // Préstamos activos que ya vencieron o vencen en 2 días o menos.
    final alertas = estado.alertas;

    return Scaffold(
      appBar: BarraDegradada(
        titulo: 'Notificaciones',
        acciones: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: estado.actualizar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ContenidoCentrado(
        child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tarjeta resumen con degradado.
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColores.degradado,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const CajaIcono(
                  icono: Icons.notifications,
                  colorIcono: Colors.white,
                  fondo: Colors.white24,
                  tamano: 60,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Préstamos para revisar',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        alertas.isEmpty
                            ? 'Todo al día'
                            : '${alertas.length} préstamos requieren atención',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          for (final p in alertas) _TarjetaAlerta(prestamo: p),
        ],
      ),
      ),
    );
  }
}

class _TarjetaAlerta extends StatelessWidget {
  final Prestamo prestamo;
  const _TarjetaAlerta({required this.prestamo});

  @override
  Widget build(BuildContext context) {
    final p = prestamo;
    final vencido = p.vencido;

    // Rojo si ya venció, ámbar si está por vencer.
    final color = vencido ? AppColores.rojo : AppColores.ambar;
    final fondo = vencido ? const Color(0xFFFCE8E6) : const Color(0xFFFFEFD9);

    final String aviso;
    if (vencido) {
      aviso = 'Vencido hace ${diasTexto(-p.diasRestantes)}';
    } else if (p.diasRestantes == 0) {
      aviso = 'Vence hoy';
    } else {
      aviso = p.diasRestantes == 1 ? 'Falta 1 día' : 'Faltan ${p.diasRestantes} días';
    }

    return Tarjeta(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CajaIcono(
                icono: Icons.schedule,
                colorIcono: color,
                fondo: fondo,
                circular: true,
              ),
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
          // Recuadro de color con la fecha de devolución.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: fondo,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: color, size: 26),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vencido
                          ? 'Debió devolverse el'
                          : 'Fecha máxima de devolución',
                      style: TextStyle(fontSize: 14, color: color),
                    ),
                    Text(
                      formatoFecha(p.fechaMaxima),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.schedule, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                aviso,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
