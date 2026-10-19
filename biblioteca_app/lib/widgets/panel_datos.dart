import 'package:flutter/material.dart';

import '../theme/app_tema.dart';

/// Un dato del panel: icono, etiqueta pequeña y valor en negrita.
class DatoPanel {
  final IconData icono;
  final String etiqueta;
  final String valor;
  final Color? colorValor;

  const DatoPanel({
    required this.icono,
    required this.etiqueta,
    required this.valor,
    this.colorValor,
  });
}

/// Recuadro gris claro que reparte varios datos en columnas iguales
/// (por ejemplo Categoría | Código | Disponibles).
class PanelDatos extends StatelessWidget {
  final List<DatoPanel> datos;

  const PanelDatos({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColores.panel,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          for (final d in datos)
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(d.icono, size: 22, color: AppColores.iconoSuave),
                  const SizedBox(height: 4),
                  Text(
                    d.etiqueta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColores.iconoSuave,
                    ),
                  ),
                  Text(
                    d.valor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: d.colorValor ?? AppColores.texto,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
