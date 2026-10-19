import 'package:flutter/material.dart';

import '../models/estudiante.dart';
import '../state/app_state.dart';
import '../theme/app_tema.dart';
import '../utils/validadores.dart';
import '../widgets/barra_degradada.dart';
import '../widgets/contenido_centrado.dart';
import '../widgets/tarjeta.dart';

/// Lista de estudiantes con la opción de registrar nuevos, editar o eliminar.
class EstudiantesScreen extends StatefulWidget {
  const EstudiantesScreen({super.key});

  @override
  State<EstudiantesScreen> createState() => _EstudiantesScreenState();
}

class _EstudiantesScreenState extends State<EstudiantesScreen> {
  void _mensaje(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _abrirFormulario([Estudiante? estudiante]) async {
    final resultado = await showDialog<Estudiante>(
      context: context,
      builder: (_) => _FormularioEstudiante(estudiante: estudiante),
    );
    if (resultado == null || !mounted) return;

    final estado = EstadoApp.leer(context);
    if (estudiante == null) {
      estado.agregarEstudiante(resultado);
    } else {
      estado.actualizarEstudiante(estudiante, resultado);
    }
    _mensaje(estudiante == null
        ? 'Estudiante registrado'
        : 'Estudiante actualizado');
  }

  Future<void> _eliminar(Estudiante estudiante) async {
    final estado = EstadoApp.leer(context);
    final motivo = estado.motivoNoEliminarEstudiante(estudiante);
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
        title: const Text('Eliminar estudiante'),
        content: Text('¿Eliminar a ${estudiante.nombre}?'),
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

    estado.eliminarEstudiante(estudiante);
    _mensaje('Estudiante eliminado');
  }

  @override
  Widget build(BuildContext context) {
    // Observa el estado: si cambia, esta pantalla se redibuja.
    final estudiantes = EstadoApp.of(context).estudiantes;

    return Scaffold(
      appBar: const BarraDegradada(
        titulo: 'Estudiantes',
        icono: Icons.people,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.person_add),
        label: const Text('Nuevo estudiante'),
      ),
      body: ContenidoCentrado(
        child: estudiantes.isEmpty
          ? const Center(child: Text('Aún no hay estudiantes registrados'))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: estudiantes.length,
              itemBuilder: (context, i) {
                final e = estudiantes[i];
                return Tarjeta(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColores.cajaIcono,
                        foregroundColor: AppColores.primario,
                        child: Icon(Icons.person),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.nombre,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColores.texto,
                              ),
                            ),
                            const SizedBox(height: 2),
                            _LineaDato(icono: Icons.sell, texto: e.codigo),
                            _LineaDato(icono: Icons.email, texto: e.correo),
                          ],
                        ),
                      ),
                      // Menú de acciones (los tres puntos).
                      PopupMenuButton<String>(
                        color: Colors.white,
                        surfaceTintColor: Colors.transparent,
                        onSelected: (accion) {
                          if (accion == 'editar') _abrirFormulario(e);
                          if (accion == 'eliminar') _eliminar(e);
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'editar', child: Text('Editar')),
                          PopupMenuItem(
                              value: 'eliminar', child: Text('Eliminar')),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      ),
    );
  }
}

/// Línea pequeña con un icono gris y un texto (código, correo...).
class _LineaDato extends StatelessWidget {
  final IconData icono;
  final String texto;
  const _LineaDato({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(icono, size: 16, color: AppColores.iconoSuave),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                color: AppColores.textoSuave,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Formulario (en un AlertDialog) para crear o editar un estudiante.
class _FormularioEstudiante extends StatefulWidget {
  final Estudiante? estudiante;
  const _FormularioEstudiante({this.estudiante});

  @override
  State<_FormularioEstudiante> createState() => _FormularioEstudianteState();
}

class _FormularioEstudianteState extends State<_FormularioEstudiante> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codigo;
  late final TextEditingController _nombre;
  late final TextEditingController _correo;

  @override
  void initState() {
    super.initState();
    final e = widget.estudiante;
    _codigo = TextEditingController(text: e?.codigo ?? '');
    _nombre = TextEditingController(text: e?.nombre ?? '');
    _correo = TextEditingController(text: e?.correo ?? '');
  }

  @override
  void dispose() {
    _codigo.dispose();
    _nombre.dispose();
    _correo.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      Estudiante(
        codigo: _codigo.text.trim().toUpperCase(),
        nombre: _nombre.text.trim(),
        correo: _correo.text.trim(),
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
          const Icon(Icons.person_add, color: AppColores.primario),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.estudiante == null
                  ? 'Nuevo estudiante'
                  : 'Editar estudiante',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColores.texto,
              ),
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
                decoration: decoracionCampo('Código (ej. EST-004)', Icons.sell),
                validator: (v) {
                  final error = Validadores.requerido(
                      v, 'Escribe el código del estudiante');
                  if (error != null) return error;
                  final repetido = EstadoApp.leer(context)
                      .codigoEstudianteRepetido(v!.trim(),
                          ignorar: widget.estudiante);
                  return repetido ? 'Ese código ya existe' : null;
                },
              ),
              TextFormField(
                controller: _nombre,
                decoration: decoracionCampo('Nombre completo', Icons.person),
                validator: (v) => Validadores.longitudMinima(
                    v, 3, 'Escribe el nombre completo'),
              ),
              TextFormField(
                controller: _correo,
                keyboardType: TextInputType.emailAddress,
                decoration: decoracionCampo('Correo', Icons.email),
                validator: Validadores.correo,
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
