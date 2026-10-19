import 'package:flutter/material.dart';

import '../models/libro.dart';
import '../state/app_state.dart';
import '../theme/app_tema.dart';
import '../utils/validadores.dart';
import '../widgets/barra_degradada.dart';
import '../widgets/caja_icono.dart';
import '../widgets/contenido_centrado.dart';
import '../widgets/estado_chip.dart';
import '../widgets/panel_datos.dart';
import '../widgets/tarjeta.dart';

/// Opciones del filtro de disponibilidad.
enum FiltroDisponibilidad { todos, disponibles, prestados }

/// Catálogo de libros: búsqueda, filtro por disponibilidad y las acciones
/// crear, editar y eliminar (RF01, RF02 y RF07).
///
/// Es un StatefulWidget porque guarda lo que cambia solo en esta pantalla (el
/// texto de búsqueda y el filtro elegido) y se refleja con setState(). Los
/// libros viven en [AppState]: al agregar, editar o eliminar, el estado avisa
/// y la pantalla se redibuja sola.
class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  String _busqueda = '';
  FiltroDisponibilidad _filtro = FiltroDisponibilidad.todos;

  /// Libros de [todos] que cumplen la búsqueda y el filtro.
  List<Libro> _filtrar(List<Libro> todos) {
    final texto = _busqueda.trim().toLowerCase();
    return todos.where((libro) {
      final coincide = libro.titulo.toLowerCase().contains(texto) ||
          libro.autor.toLowerCase().contains(texto) ||
          libro.codigo.toLowerCase().contains(texto);
      final cumpleFiltro = switch (_filtro) {
        FiltroDisponibilidad.todos => true,
        FiltroDisponibilidad.disponibles => libro.disponible,
        FiltroDisponibilidad.prestados => !libro.disponible,
      };
      return coincide && cumpleFiltro;
    }).toList();
  }

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  /// Abre el formulario para crear (libro == null) o editar un libro.
  Future<void> _abrirFormulario([Libro? libro]) async {
    final resultado = await showDialog<Libro>(
      context: context,
      builder: (_) => _FormularioLibro(libro: libro),
    );
    if (resultado == null || !mounted) return; // canceló o salió de la pantalla

    final estado = EstadoApp.leer(context);
    if (libro == null) {
      estado.agregarLibro(resultado);
    } else {
      estado.actualizarLibro(libro, resultado);
    }
    _mensaje(libro == null ? 'Libro registrado' : 'Libro actualizado');
  }

  Future<void> _eliminar(Libro libro) async {
    final estado = EstadoApp.leer(context);
    final motivo = estado.motivoNoEliminarLibro(libro);
    if (motivo != null) {
      _mensaje(motivo);
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Eliminar libro'),
        content: Text('¿Eliminar "${libro.titulo}" del catálogo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColores.rojo),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;

    estado.eliminarLibro(libro);
    _mensaje('Libro eliminado');
  }

  @override
  Widget build(BuildContext context) {
    // Observa el estado: si cambia, esta pantalla se redibuja.
    final libros = _filtrar(EstadoApp.of(context).libros);

    return Scaffold(
      appBar: const BarraDegradada(
        titulo: 'Catálogo de libros',
        icono: Icons.menu_book,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo libro'),
      ),
      body: ContenidoCentrado(
        child: Column(
        children: [
          // Fila de búsqueda + filtro.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar libro',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: AppColores.borde),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: AppColores.primario,
                          width: 1.6,
                        ),
                      ),
                    ),
                    onChanged: (texto) => setState(() => _busqueda = texto),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColores.borde),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<FiltroDisponibilidad>(
                      value: _filtro,
                      borderRadius: BorderRadius.circular(16),
                      items: const [
                        DropdownMenuItem(
                          value: FiltroDisponibilidad.todos,
                          child: Text('Todos'),
                        ),
                        DropdownMenuItem(
                          value: FiltroDisponibilidad.disponibles,
                          child: Text('Disponibles'),
                        ),
                        DropdownMenuItem(
                          value: FiltroDisponibilidad.prestados,
                          child: Text('Prestados'),
                        ),
                      ],
                      onChanged: (valor) {
                        if (valor != null) setState(() => _filtro = valor);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: libros.isEmpty
                ? const Center(child: Text('No hay libros que coincidan'))
                // ListView.builder construye cada tarjeta solo cuando se ve.
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    itemCount: libros.length,
                    itemBuilder: (context, i) => _TarjetaLibro(
                      libro: libros[i],
                      alEditar: () => _abrirFormulario(libros[i]),
                      alEliminar: () => _eliminar(libros[i]),
                    ),
                  ),
          ),
        ],
      ),
      ),
    );
  }
}

/// Tarjeta con los datos de un libro y los botones Editar y Eliminar.
class _TarjetaLibro extends StatelessWidget {
  final Libro libro;
  final VoidCallback alEditar;
  final VoidCallback alEliminar;

  const _TarjetaLibro({
    required this.libro,
    required this.alEditar,
    required this.alEliminar,
  });

  @override
  Widget build(BuildContext context) {
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
                      libro.titulo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColores.texto,
                      ),
                    ),
                    Text(
                      libro.autor,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColores.textoSuave,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              EstadoChip.deLibro(libro),
            ],
          ),
          const SizedBox(height: 12),
          PanelDatos(
            datos: [
              DatoPanel(
                icono: Icons.category,
                etiqueta: 'Categoría',
                valor: libro.categoria,
              ),
              DatoPanel(
                icono: Icons.sell,
                etiqueta: 'Código',
                valor: libro.codigo,
              ),
              DatoPanel(
                icono: Icons.check_circle,
                etiqueta: 'Disponibles',
                valor: '${libro.ejemplaresDisponibles}/${libro.ejemplaresTotal}',
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: alEditar,
                icon: const Icon(Icons.edit),
                label: const Text('Editar'),
              ),
              TextButton.icon(
                onPressed: alEliminar,
                style: TextButton.styleFrom(foregroundColor: AppColores.rojo),
                icon: const Icon(Icons.delete),
                label: const Text('Eliminar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Formulario (en un AlertDialog) para crear o editar un libro, con
/// validación de campos. Devuelve el Libro con los datos escritos.
class _FormularioLibro extends StatefulWidget {
  final Libro? libro;
  const _FormularioLibro({this.libro});

  @override
  State<_FormularioLibro> createState() => _FormularioLibroState();
}

class _FormularioLibroState extends State<_FormularioLibro> {
  // La llave permite validar todos los campos del Form a la vez.
  final _formKey = GlobalKey<FormState>();

  // Cada controlador guarda el texto de su campo.
  late final TextEditingController _codigo;
  late final TextEditingController _titulo;
  late final TextEditingController _autor;
  late final TextEditingController _categoria;
  late final TextEditingController _ejemplares;

  bool get _esEdicion => widget.libro != null;

  @override
  void initState() {
    super.initState();
    final l = widget.libro;
    _codigo = TextEditingController(text: l?.codigo ?? '');
    _titulo = TextEditingController(text: l?.titulo ?? '');
    _autor = TextEditingController(text: l?.autor ?? '');
    _categoria = TextEditingController(text: l?.categoria ?? '');
    _ejemplares = TextEditingController(text: l == null ? '' : '${l.ejemplaresTotal}');
  }

  @override
  void dispose() {
    _codigo.dispose();
    _titulo.dispose();
    _autor.dispose();
    _categoria.dispose();
    _ejemplares.dispose();
    super.dispose();
  }

  void _guardar() {
    // validate() ejecuta los validator de todos los campos.
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(
      context,
      Libro(
        codigo: _codigo.text.trim().toUpperCase(),
        titulo: _titulo.text.trim(),
        autor: _autor.text.trim(),
        categoria:
            _categoria.text.trim().isEmpty ? 'General' : _categoria.text.trim(),
        ejemplaresTotal: int.parse(_ejemplares.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Row(
        children: [
          const Icon(Icons.menu_book, color: AppColores.primario),
          const SizedBox(width: 12),
          Text(
            _esEdicion ? 'Editar libro' : 'Nuevo libro',
            style: const TextStyle(
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
              TextFormField(
                controller: _codigo,
                decoration: decoracionCampo('Código', Icons.sell),
                validator: (v) {
                  final error =
                      Validadores.requerido(v, 'Escribe el código del libro');
                  if (error != null) return error;
                  final repetido = EstadoApp.leer(context)
                      .codigoLibroRepetido(v!.trim(), ignorar: widget.libro);
                  return repetido ? 'Ese código ya existe' : null;
                },
              ),
              TextFormField(
                controller: _titulo,
                decoration: decoracionCampo('Título', Icons.menu_book),
                validator: (v) =>
                    Validadores.requerido(v, 'Escribe el título del libro'),
              ),
              TextFormField(
                controller: _autor,
                decoration: decoracionCampo('Autor', Icons.person),
                validator: (v) =>
                    Validadores.requerido(v, 'Escribe el autor del libro'),
              ),
              TextFormField(
                controller: _categoria,
                decoration: decoracionCampo('Categoría', Icons.category),
              ),
              TextFormField(
                controller: _ejemplares,
                keyboardType: TextInputType.number,
                decoration:
                    decoracionCampo('Cantidad de ejemplares', Icons.article),
                validator: (v) => Validadores.enteroMinimo(v, 1),
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
          icon: const Icon(Icons.save),
          label: const Text('Guardar'),
        ),
      ],
    );
  }
}
