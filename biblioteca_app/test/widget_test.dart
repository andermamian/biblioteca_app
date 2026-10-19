import 'package:biblioteca_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('el menú principal navega al catálogo', (tester) async {
    await tester.pumpWidget(const BibliotecaApp());

    expect(find.text('Bienvenido'), findsOneWidget);
    expect(find.text('Catálogo de libros'), findsOneWidget);

    await tester.tap(find.text('Catálogo de libros'));
    await tester.pumpAndSettle();

    expect(find.text('Cien años de soledad'), findsOneWidget);
  });

  testWidgets('el formulario de libro muestra errores de validación',
      (tester) async {
    await tester.pumpWidget(const BibliotecaApp());

    await tester.tap(find.text('Catálogo de libros'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Nuevo libro'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.text('Escribe el título del libro'), findsOneWidget);
  });
}
