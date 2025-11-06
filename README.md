
# App Movies
![demo](<Imagen de WhatsApp 2025-11-05 a las 19.02.33_e76d80fc.jpg>)
![detalles](<Imagen de WhatsApp 2025-11-05 a las 19.02.32_e9edefde.jpg>)
Aplicación Flutter que replica una experiencia de exploración de películas inspirada en el diseño proporcionado. Consume la API de TMDB para listar estrenos, tendencias, búsqueda y mostrar fichas detalladas con reparto.

## Vista previa

<em>Coloca aquí tus capturas</em> (por ejemplo en `assets/readme`) y embebe las imágenes que necesites.

## Características
- Catálogo principal con carrusel de pósters, selector de fechas y sección de “Trailers”.
- Pantalla de detalle con transición `Hero`, calificación dinámica, metadata y reparto.
- Búsqueda en vivo contra TMDB.
- Gestión de estado con `Provider` + `ChangeNotifier`.
- Caché de imágenes mediante `cached_network_image`.

## Requisitos
- Flutter 3.19 o superior (Dart 3.9+).
- Cuenta en [TMDB](https://www.themoviedb.org/) con **Read Access Token (v4 auth)**.

## Configuración rápida
1. Duplica el archivo `lib/core/config.dart` o edítalo y coloca tu token:
   ```dart
   const String tmdbReadAccessToken = '<tu_token_v4>';
   ```
   > Recomendado: pásalo como define para no versionarlo.
2. Instala dependencias:
   ```sh
   flutter pub get
   ```
3. Ejecuta la app con tu token:
   ```sh
   flutter run --dart-define=TMDB_READ_ACCESS_TOKEN=eyJhbGciOi...
   ```
4. Opcional: especifica idioma TMDB
   ```sh
   flutter run --dart-define=TMDB_LANGUAGE=es-MX
   ```

## Scripts útiles
- `flutter analyze` — análisis estático.
- `flutter test` — pruebas de widgets.
- `dart format lib test` — formato del código.

## Estructura relevante
```
lib/
  core/          // Configuración y helpers
  controllers/   // ChangeNotifiers
  models/        // Modelos TMDB (summary & detail)
  services/      // Cliente HTTP para TMDB
  screens/       // Pantallas principal y detalle
  widgets/       // Componentes reutilizables (chips, cards, etc.)
```

## Personalización
- Ajusta colores en `lib/theme/app_theme.dart`.
- Cambia el idioma por defecto modificando `tmdbLanguage` en `lib/core/config.dart`.
- Para ambientes de build usa el define `--dart-define-from-file=env.json` si prefieres gestionar múltiples tokens.

---
Hecho con Flutter ❤️ y la API de TMDB.
