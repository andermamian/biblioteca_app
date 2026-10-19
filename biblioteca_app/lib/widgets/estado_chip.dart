import 'package:flutter/material.dart';

import '../models/libro.dart';
import '../models/prestamo.dart';
import '../theme/app_tema.dart';

/// Etiqueta con borde de color que muestra un estado (Disponible, Prestado,
/// Activo, Vencido...).
///
/// Es un widget reutilizable: todas las pantallas lo usan, así el aspecto de
/// los estados es igual en toda la aplicación sin repetir código.
class EstadoChip extends StatelessWidget {
  final String texto;
  final Color color;

  const EstadoChip({super.key, required this.texto, required this.color});

  /// Estado de un libro: Disponible o Prestado.
  factory EstadoChip.deLibro(Libro libro) {
    return libro.disponible
        ? const EstadoChip(texto: 'Disponible', color: AppColores.verde)
        : const EstadoChip(texto: 'Prestado', color: AppColores.ambar);
  }

  /// Estado de un préstamo: Devuelto, Vencido, Por vencer o Activo.
  factory EstadoChip.dePrestamo(Prestamo p) {
    if (!p.activo) {
      return const EstadoChip(texto: 'Devuelto', color: AppColores.verde);
    }
    if (p.vencido) {
      return const EstadoChip(texto: 'Vencido', color: AppColores.rojo);
    }
    if (p.porVencer) {
      return const EstadoChip(texto: 'Por vencer', color: AppColores.ambar);
    }
    return const EstadoChip(texto: 'Activo', color: AppColores.azul);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        // Fondo = el mismo color, muy suave, mezclado con blanco.
        color: Color.alphaBlend(color.withAlpha(24), Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.4),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: color,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
