import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/home_screen.dart';
import 'state/app_state.dart';
import 'theme/app_tema.dart';

/// Punto de entrada: Flutter ejecuta main() al abrir la aplicación.
void main() => runApp(const BibliotecaApp());

/// Widget raíz. Crea el estado de la aplicación una sola vez y lo comparte
/// con todas las pantallas mediante [EstadoApp].
class BibliotecaApp extends StatefulWidget {
  const BibliotecaApp({super.key});

  @override
  State<BibliotecaApp> createState() => _BibliotecaAppState();
}

class _BibliotecaAppState extends State<BibliotecaApp> {
  final AppState _estado = AppState();

  @override
  void dispose() {
    _estado.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EstadoApp(
      estado: _estado,
      child: MaterialApp(
        title: 'Biblioteca Escolar',
        debugShowCheckedModeBanner: false,
        theme: crearTema(),
        // Textos de Material (calendario, botones de diálogos) en español.
        locale: const Locale('es', 'CO'),
        supportedLocales: const [Locale('es', 'CO'), Locale('es')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: const HomeScreen(),
      ),
    );
  }
}
