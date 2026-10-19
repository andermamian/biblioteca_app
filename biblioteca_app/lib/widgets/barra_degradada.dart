import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_tema.dart';
import 'caja_icono.dart';

/// Barra superior de las pantallas internas: flecha de regreso, icono
/// opcional, título y acciones, sobre el degradado índigo.
///
/// Implementa PreferredSizeWidget para poder usarse como `appBar:` de un
/// Scaffold.
class BarraDegradada extends StatelessWidget implements PreferredSizeWidget {
  final String titulo;
  final IconData? icono;
  final List<Widget>? acciones;

  const BarraDegradada({
    super.key,
    required this.titulo,
    this.icono,
    this.acciones,
  });

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 68,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      // El degradado se dibuja detrás de la barra.
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: AppColores.degradado),
      ),
      titleSpacing: icono == null ? null : 0,
      title: Row(
        children: [
          if (icono != null) ...[
            CajaIcono(
              icono: icono!,
              colorIcono: Colors.white,
              fondo: Colors.white24,
              tamano: 40,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              titulo,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      actions: acciones,
    );
  }
}
