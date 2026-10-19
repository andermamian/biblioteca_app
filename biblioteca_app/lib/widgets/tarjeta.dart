import 'package:flutter/material.dart';

/// Tarjeta blanca con esquinas redondeadas y sombra suave.
///
/// Widget reutilizable: todas las pantallas la usan, así las tarjetas se ven
/// igual en toda la app. Si recibe [alTocar], reacciona al toque.
class Tarjeta extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? alTocar;

  const Tarjeta({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: 12),
    this.alTocar,
  });

  @override
  Widget build(BuildContext context) {
    final forma = BorderRadius.circular(20);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: forma,
        boxShadow: const [
          BoxShadow(
            color: Color(0x143949AB),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: forma,
          onTap: alTocar,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
