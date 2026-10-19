import 'package:flutter/material.dart';

import '../theme/app_tema.dart';

/// Icono dentro de un recuadro de color (cuadrado redondeado o círculo).
/// Se usa en el menú, en las tarjetas y en las barras superiores.
class CajaIcono extends StatelessWidget {
  final IconData icono;
  final Color colorIcono;
  final Color fondo;
  final double tamano;
  final bool circular;

  const CajaIcono({
    super.key,
    required this.icono,
    this.colorIcono = AppColores.primario,
    this.fondo = AppColores.cajaIcono,
    this.tamano = 48,
    this.circular = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(
        color: fondo,
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circular ? null : BorderRadius.circular(tamano * 0.3),
      ),
      child: Icon(icono, color: colorIcono, size: tamano * 0.5),
    );
  }
}
