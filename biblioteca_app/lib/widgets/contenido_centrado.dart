import 'package:flutter/material.dart';

/// Centra el contenido y limita su ancho máximo.
///
/// Es la base del diseño responsivo: en un celular el contenido ocupa todo el
/// ancho, y en una tableta o en una ventana grande no se estira demasiado.
class ContenidoCentrado extends StatelessWidget {
  final Widget child;
  final double anchoMaximo;

  const ContenidoCentrado({
    super.key,
    required this.child,
    this.anchoMaximo = 720,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: anchoMaximo),
        child: child,
      ),
    );
  }
}
