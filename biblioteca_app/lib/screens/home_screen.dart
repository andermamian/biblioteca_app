import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_tema.dart';
import '../widgets/caja_icono.dart';
import '../widgets/contenido_centrado.dart';
import '../widgets/tarjeta.dart';
import 'catalogo_screen.dart';
import 'estudiantes_screen.dart';
import 'historial_screen.dart';
import 'notificaciones_screen.dart';
import 'prestamos_screen.dart';

/// Pantalla principal: encabezado con degradado y menú con las cinco
/// secciones de la aplicación. El menú se adapta al ancho de la pantalla.
///
/// Es un StatelessWidget porque no cambia: solo muestra opciones y navega.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Iconos claros en la barra de estado, porque el encabezado es oscuro.
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Column(
          children: [
            const _Encabezado(),
            Expanded(
              child: ContenidoCentrado(
                anchoMaximo: 900,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'Bienvenido',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppColores.texto,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(4, 2, 4, 16),
                      child: Text(
                        '¿Qué deseas hacer hoy?',
                        style: TextStyle(
                          fontSize: 17,
                          color: AppColores.textoSuave,
                        ),
                      ),
                    ),
                    // Diseño responsivo: 1 columna en el celular y 2 columnas
                    // cuando hay ancho de sobra (tableta o ventana grande).
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final columnas = constraints.maxWidth >= 640 ? 2 : 1;
                        const separacion = 12.0;
                        final ancho = (constraints.maxWidth -
                                separacion * (columnas - 1)) /
                            columnas;
                        return Wrap(
                          spacing: separacion,
                          children: [
                            for (final opcion in _opciones)
                              SizedBox(width: ancho, child: opcion),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Las cinco opciones del menú.
  static const List<Widget> _opciones = [
    _OpcionMenu(
      icono: Icons.menu_book,
      colorIcono: AppColores.primario,
      fondo: Color(0xFFE8EAF6),
      titulo: 'Catálogo de libros',
      descripcion: 'Buscar, registrar, editar y eliminar libros',
      destino: CatalogoScreen(),
    ),
    _OpcionMenu(
      icono: Icons.people,
      colorIcono: Color(0xFF1B7A4F),
      fondo: Color(0xFFDCF1E8),
      titulo: 'Estudiantes',
      descripcion: 'Registrar estudiantes para asociarlos a préstamos',
      destino: EstudiantesScreen(),
    ),
    _OpcionMenu(
      icono: Icons.swap_horiz,
      colorIcono: Color(0xFFB8651B),
      fondo: Color(0xFFFFE9D6),
      titulo: 'Préstamos',
      descripcion: 'Registrar préstamos y devoluciones',
      destino: PrestamosScreen(),
    ),
    _OpcionMenu(
      icono: Icons.history,
      colorIcono: Color(0xFF6A3FA0),
      fondo: Color(0xFFEADDF5),
      titulo: 'Historial',
      descripcion: 'Consultar historial por estudiante o por libro',
      destino: HistorialScreen(),
    ),
    _OpcionMenu(
      icono: Icons.notifications,
      colorIcono: AppColores.rojo,
      fondo: Color(0xFFF9DCE3),
      titulo: 'Notificaciones',
      descripcion: 'Préstamos próximos a vencer o vencidos',
      destino: NotificacionesScreen(),
    ),
  ];
}

/// Encabezado con degradado y esquinas inferiores redondeadas.
class _Encabezado extends StatelessWidget {
  const _Encabezado();

  @override
  Widget build(BuildContext context) {
    // Espacio de la barra de estado del teléfono (hora, batería...).
    final arriba = MediaQuery.paddingOf(context).top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, arriba + 16, 20, 24),
      decoration: const BoxDecoration(
        gradient: AppColores.degradado,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: const Row(
        children: [
          CajaIcono(
            icono: Icons.menu_book,
            colorIcono: Colors.white,
            fondo: Colors.white24,
            tamano: 60,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Biblioteca Escolar',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Gestión de biblioteca',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta del menú: icono de color, título, descripción y flecha.
/// Al tocarla abre la pantalla [destino] con Navigator.push.
class _OpcionMenu extends StatelessWidget {
  final IconData icono;
  final Color colorIcono;
  final Color fondo;
  final String titulo;
  final String descripcion;
  final Widget destino;

  const _OpcionMenu({
    required this.icono,
    required this.colorIcono,
    required this.fondo,
    required this.titulo,
    required this.descripcion,
    required this.destino,
  });

  @override
  Widget build(BuildContext context) {
    return Tarjeta(
      padding: const EdgeInsets.all(14),
      alTocar: () {
        // Apila la nueva pantalla; el botón "atrás" la retira.
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => destino),
        );
      },
      child: Row(
        children: [
          CajaIcono(
            icono: icono,
            colorIcono: colorIcono,
            fondo: fondo,
            tamano: 56,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColores.texto,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  descripcion,
                  style: const TextStyle(
                    fontSize: 14.5,
                    color: AppColores.textoSuave,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColores.iconoSuave),
        ],
      ),
    );
  }
}
