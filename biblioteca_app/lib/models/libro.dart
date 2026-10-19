/// Un libro del catálogo.
///
/// Los campos no son `final` porque en esta fase la lista vive en memoria y
/// las pantallas editan los objetos directamente.
class Libro {
  String codigo;
  String titulo;
  String autor;
  String categoria;
  int ejemplaresTotal;
  int ejemplaresDisponibles;

  Libro({
    required this.codigo,
    required this.titulo,
    required this.autor,
    this.categoria = 'General',
    required this.ejemplaresTotal,
    int? ejemplaresDisponibles,
  }) : ejemplaresDisponibles = ejemplaresDisponibles ?? ejemplaresTotal;

  /// Un libro está disponible si le queda al menos un ejemplar.
  bool get disponible => ejemplaresDisponibles > 0;

  /// Copia los datos editados en el formulario, conservando los ejemplares
  /// que están prestados.
  void actualizarDesde(Libro otro) {
    final prestados = ejemplaresTotal - ejemplaresDisponibles;
    codigo = otro.codigo;
    titulo = otro.titulo;
    autor = otro.autor;
    categoria = otro.categoria;
    ejemplaresTotal = otro.ejemplaresTotal;
    ejemplaresDisponibles =
        (ejemplaresTotal - prestados).clamp(0, ejemplaresTotal);
  }
}
