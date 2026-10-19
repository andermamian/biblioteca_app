# Biblioteca Escolar — Guía de instalación y ejecución

Aplicación móvil hecha con Flutter para llevar el control de préstamos de libros de la
biblioteca escolar (Sede 2). Corresponde a la **Fase 3** del curso *Framework para el
Desarrollo de Aplicaciones Móviles* (UNAD): interfaces, navegación, formularios con
validación, estado compartido y diseño responsivo.

> **Importante:** los datos son de ejemplo y viven en memoria. No hay base de datos ni
> servicios del dispositivo (cámara, notificaciones del sistema). Al cerrar la app, los
> cambios se pierden.

---

## 1. Requisitos

| Herramienta | Versión | Para qué sirve |
|---|---|---|
| Windows 10 u 11 (64 bits) | — | Sistema operativo (en Linux y macOS los pasos son análogos) |
| Flutter SDK | 3.x estable (probado con 3.47) | Framework y comandos `flutter` |
| Android Studio | Reciente | SDK de Android y emulador |
| Emulador Android | Pixel 9 Pro, API 36 (o cualquier API 24 o superior) | Ejecutar la app |
| Git (opcional) | Cualquiera | Solo si clonas el repositorio |

El proyecto declara `sdk: '>=3.4.0 <4.0.0'` en `pubspec.yaml`.

Dependencias del proyecto (se instalan solas con `flutter pub get`): `flutter`,
`flutter_localizations`, `cupertino_icons` y, para desarrollo, `flutter_test` y
`flutter_lints`. No se usan paquetes de terceros adicionales.

---

## 2. Instalar el entorno (una sola vez)

1. **Flutter SDK.** Descárgalo desde <https://docs.flutter.dev/get-started/install>,
   descomprímelo en una carpeta sin espacios (por ejemplo `C:\src\flutter`) y agrega
   `C:\src\flutter\bin` a la variable de entorno `Path`.
2. **Android Studio.** Instálalo desde <https://developer.android.com/studio>. En el primer
   inicio acepta la instalación del *Android SDK*, *Platform-Tools* y *Command-line Tools*.
3. **Licencias de Android.** En PowerShell:

   ```powershell
   flutter doctor --android-licenses
   ```

4. **Emulador.** En Android Studio abre *Device Manager* → *Create Device* → elige
   *Pixel 9 Pro* → descarga una imagen del sistema (API 36 o similar) → *Finish*.
5. **Verifica la instalación:**

   ```powershell
   flutter doctor
   ```

   Debe mostrar una marca verde en *Flutter*, *Android toolchain* y *Android Studio*.

---

## 3. Obtener el proyecto

Descomprime `biblioteca_app.zip` (o clona el repositorio) y **ubica la carpeta en una ruta
sin tildes, eñes ni caracteres especiales**, por ejemplo:

```
C:\dev\biblioteca_app
```

Gradle (la herramienta que compila para Android) falla con rutas como
`...\Móviles\biblioteca_app`. Si tu copia está en una ruta con caracteres especiales,
duplícala antes de ejecutar:

```powershell
robocopy "RUTA_ORIGINAL\biblioteca_app" "C:\dev\biblioteca_app" /MIR /XD build .dart_tool .gradle .idea
```

Si la carpeta no incluye `android/` (por ejemplo, porque solo recibiste `lib/`, `test/` y
`pubspec.yaml`), genera los archivos de plataforma **una sola vez**, dentro de la carpeta del
proyecto:

```powershell
cd C:\dev\biblioteca_app
flutter create . --platforms=android --project-name biblioteca_app
```

Este comando no reemplaza el código de `lib/`.

---

## 4. Ejecutar la aplicación

1. **Enciende el emulador** (Device Manager → botón ▶) o desde PowerShell:

   ```powershell
   flutter emulators --launch Pixel_9_Pro
   ```

2. **Espera** a que cargue la pantalla de inicio de Android y confirma que Flutter lo ve:

   ```powershell
   flutter devices
   ```

   Debe aparecer una línea como `emulator-5554 • Pixel 9 Pro • android-x64`.

3. **Instala las dependencias y ejecuta**, escribiendo el id real del dispositivo
   (no escribas los símbolos `< >`):

   ```powershell
   cd C:\dev\biblioteca_app
   flutter pub get
   flutter run -d emulator-5554
   ```

   La primera compilación tarda varios minutos mientras Gradle descarga componentes.
   Al terminar se abre el menú **Biblioteca Escolar** en el emulador.

Mientras la app corre, en la terminal puedes pulsar:

| Tecla | Acción |
|---|---|
| `r` | *Hot reload*: aplica cambios de código sin reiniciar |
| `R` | *Hot restart*: reinicia la app |
| `q` | Cierra la aplicación |

---

## 5. Ejecutar las pruebas

```powershell
cd C:\dev\biblioteca_app
flutter test
```

Se ejecutan tres archivos de `test/`:

| Archivo | Qué comprueba |
|---|---|
| `validadores_test.dart` | Reglas de validación: obligatorio, mínimo, número y correo |
| `app_state_test.dart` | Estado: agregar libros, préstamos, devoluciones y reglas de eliminación |
| `widget_test.dart` | Navegación del menú al catálogo y mensaje de error del formulario |

---

## 6. Qué puedes hacer en la app

| Pantalla | Funciones |
|---|---|
| Menú principal | Acceso a las cinco secciones; el menú pasa de 1 a 2 columnas en pantallas anchas |
| Catálogo de libros | Buscar por título, autor o código; filtrar por disponibilidad; crear, editar y eliminar |
| Estudiantes | Registrar, editar y eliminar estudiantes (menú de tres puntos) |
| Préstamos | Registrar un préstamo con libro, estudiante y fecha máxima; registrar la devolución |
| Historial | Consultar préstamos por estudiante o por libro |
| Notificaciones | Préstamos vencidos o por vencer en los próximos 2 días |

Reglas de negocio incluidas: un libro con préstamos sin devolver no se puede eliminar; un
estudiante con préstamos registrados no se puede eliminar; solo se pueden prestar libros con
ejemplares disponibles; los códigos de libro y de estudiante no se repiten.

---

## 7. Estructura del proyecto

```
lib/
├── main.dart                   Arranque, tema, idioma y estado de la app
├── theme/app_tema.dart         Paleta de colores y tema Material 3
├── state/app_state.dart        AppState (ChangeNotifier) y EstadoApp (InheritedNotifier)
├── models/                     Libro, Estudiante, Prestamo
├── data/datos_ejemplo.dart     Datos con los que arranca la app
├── utils/                      formato.dart y validadores.dart
├── widgets/                    Componentes reutilizables
│   ├── barra_degradada.dart    Barra superior con degradado
│   ├── tarjeta.dart            Tarjeta blanca con sombra
│   ├── caja_icono.dart         Icono dentro de un recuadro de color
│   ├── panel_datos.dart        Recuadro con datos en columnas
│   ├── contenido_centrado.dart Ancho máximo para pantallas grandes
│   └── estado_chip.dart        Etiqueta de estado (Activo, Vencido...)
└── screens/                    Una pantalla por archivo
test/                           Pruebas automáticas
```

---

## 8. Solución de problemas

| Síntoma | Causa y solución |
|---|---|
| `No supported devices found with name or id matching 'emulator-5554'` | El emulador está apagado o tiene otro id. Enciéndelo y revisa `flutter devices`. |
| `flutter devices` solo muestra Windows, Chrome y Edge | El emulador no ha terminado de arrancar. Espera un minuto y repite. |
| `The '<' operator is reserved for future use` | Pegaste `<dispositivo>` tal cual. Reemplázalo por el id real, por ejemplo `emulator-5554`. |
| `Error on line 2 ... Mapping values are not allowed here` en `pubspec.yaml` | La descripción del `pubspec.yaml` tiene un `:`. Quita los dos puntos o pon el texto entre comillas. |
| `project path contains non-ASCII characters` o falla Gradle | La ruta tiene tildes o caracteres especiales. Copia el proyecto a `C:\dev\biblioteca_app`. |
| `AndroidManifest.xml could not be found` | Falta la carpeta `android/`. Ejecuta `flutter create . --platforms=android --project-name biblioteca_app`. |
| El emulador muestra el contador "Flutter Demo Home Page" | Se está ejecutando el proyecto de ejemplo, no este. Copia `lib/`, `test/` y `pubspec.yaml` en la carpeta correcta y vuelve a ejecutar `flutter run`. |
| La app se instala pero se ve la versión anterior | Ejecuta `flutter clean`, luego `flutter pub get` y `flutter run -d emulator-5554`. |
| `Gradle` tarda mucho la primera vez | Es normal: descarga dependencias. Las siguientes ejecuciones son rápidas. |
| `flutter` no se reconoce como comando | `C:\src\flutter\bin` no está en el `Path`. Agrégalo y abre una terminal nueva. |

---

## 9. Créditos

Proyecto colaborativo del grupo 202047929_6, Tecnología en Desarrollo de Software,
Universidad Nacional Abierta y a Distancia (UNAD).
