/// Convierte una fecha a texto con el formato dd/MM/yyyy (ej. 05/10/2026).
String formatoFecha(DateTime fecha) {
  final dia = fecha.day.toString().padLeft(2, '0');
  final mes = fecha.month.toString().padLeft(2, '0');
  return '$dia/$mes/${fecha.year}';
}

/// "1 día" / "3 días".
String diasTexto(int n) => n == 1 ? '$n día' : '$n días';
