# Roku TMDB App

Una aplicación Roku que muestra películas populares de The Movie Database (TMDB) con una interfaz estilo Netflix.

## Características

- 🎬 Muestra las 10 películas más populares de TMDB
- 🎨 Interfaz estilo Netflix con navegación fluida
- 📱 Detalles completos de películas (fecha, calificación, descripción)
- 🎥 Sistema de trailers externos desde GitHub
- 🌍 Soporte para trailers en español e inglés
- ⚡ Sistema de cache para mejor rendimiento

## Estructura del Proyecto

```
├── manifest                 # Configuración de la aplicación Roku
├── components/             # Componentes SceneGraph
│   ├── MainScene.xml      # Interfaz principal
│   ├── MainScene.brs      # Lógica de la interfaz
│   └── ...                # Otros componentes
├── source/                # Código fuente principal
│   ├── main.brs          # Punto de entrada y manejo de APIs
│   └── fetchMovieData.brs # Funciones de extracción de datos
├── images/               # Recursos gráficos
└── trailers.json        # Base de datos de trailers (para GitHub)
```

## Configuración

### Requisitos

- Roku Developer Account
- TMDB API Key
- Repositorio GitHub para trailers externos

### Instalación

1. Clona este repositorio
2. Configura tu TMDB API key en `source/main.brs`
3. Configura la URL de tu repositorio de trailers en `source/main.brs`
4. Sube a tu Roku usando Developer Mode

## Sistema de Trailers Externos

Este proyecto incluye un sistema innovador que permite mantener las URLs de trailers en un archivo JSON externo alojado en GitHub. Esto permite:

- ✅ Actualizaciones de trailers sin recompilar la aplicación
- ✅ Control total sobre qué trailers mostrar
- ✅ Mejor rendimiento con sistema de cache
- ✅ Fallback automático a la API de TMDB

Para más detalles, consulta [TRAILERS_README.md](TRAILERS_README.md).

## API de TMDB

Esta aplicación utiliza The Movie Database (TMDB) API:
- **Películas populares**: Para obtener la lista principal
- **Videos**: Como fallback para trailers
- **Imágenes**: Para posters y backdrops

## Desarrollo

### Estructura de Datos

Las películas contienen:
- ID, título, descripción
- Fecha de lanzamiento
- Calificación promedio
- URLs de imágenes optimizadas

### Threading

- **Main Thread**: Maneja requests HTTP y lógica de negocio
- **Render Thread**: Maneja la interfaz SceneGraph

## Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature
3. Commit tus cambios
4. Push a la rama
5. Abre un Pull Request

## Licencia

Este proyecto es de código abierto. Úsalo libremente para aprender y desarrollar.

## Créditos

- **TMDB**: Por la excelente API de películas
- **Roku**: Por la plataforma SceneGraph
- **YouTube**: Por alojar los trailers