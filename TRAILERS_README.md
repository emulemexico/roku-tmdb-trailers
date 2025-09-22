# Sistema de Trailers Directos para Roku TMDB App

## Descripción

Este sistema permite mantener URLs directos de trailers de películas en un archivo JSON externo alojado en GitHub, facilitando las actualizaciones sin necesidad de modificar el código de la aplicación Roku. El sistema soporta múltiples formatos de video incluyendo HLS, MP4, DASH y URLs de YouTube.

## Estructura del Archivo JSON

El archivo `trailers.json` debe tener la siguiente estructura:

```json
{
  "version": "2.0",
  "last_updated": "2025-09-22",
  "description": "Archivo de URLs directos de trailers para películas TMDB",
  "trailers": {
    "MOVIE_ID": {
      "title": "Título de la Película",
      "video_url": "https://ejemplo.com/video.m3u8",
      "language": "es",
      "type": "Trailer",
      "quality": "HD",
      "format": "HLS"
    }
  },
  "supported_formats": {
    "HLS": "HTTP Live Streaming (.m3u8) - Recomendado para Roku",
    "MP4": "MPEG-4 directo - Compatible con Roku", 
    "YOUTUBE": "URLs de YouTube - Requieren procesamiento adicional",
    "DASH": "Dynamic Adaptive Streaming - Compatible con Roku"
  }
}
```

### Campos Obligatorios

- **MOVIE_ID**: El ID de la película en TMDB (como string)
- **title**: Título de la película
- **video_url**: URL directo del trailer (HLS, MP4, DASH, etc.)
- **language**: Idioma del trailer (es, en, etc.)
- **type**: Tipo de video (Trailer, Teaser, Clip)
- **quality**: Calidad del video (HD, SD, 4K)
- **format**: Formato del video (HLS, MP4, DASH, YOUTUBE)

## Formatos de Video Soportados

### 🎥 HLS (HTTP Live Streaming) - RECOMENDADO
- **Extensión**: `.m3u8`
- **Ventajas**: Streaming adaptativo, mejor para conexiones variables
- **Ejemplo**: `https://ejemplo.com/video/playlist.m3u8`
- **Compatibilidad**: ✅ Roku nativo

### 🎬 MP4 (MPEG-4)
- **Extensión**: `.mp4`
- **Ventajas**: Simple, directo, buena calidad
- **Ejemplo**: `https://ejemplo.com/video.mp4`
- **Compatibilidad**: ✅ Roku nativo

### 📺 DASH (Dynamic Adaptive Streaming)
- **Extensión**: `.mpd`
- **Ventajas**: Streaming adaptativo avanzado
- **Ejemplo**: `https://ejemplo.com/video.mpd`
- **Compatibilidad**: ✅ Roku nativo

### 🔗 YouTube URLs
- **Formato**: URLs de YouTube
- **Uso**: Para referencia o procesamiento externo
- **Ejemplo**: `https://www.youtube.com/watch?v=VIDEO_ID`
- **Compatibilidad**: ⚠️ Requiere procesamiento adicional

## Configuración en GitHub

### 1. Crear Repositorio

1. Crea un nuevo repositorio público en GitHub
2. Sube el archivo `trailers.json` al repositorio
3. Obtén la URL raw del archivo

### 2. Actualizar URL en el Código

En el archivo `source/main.brs`, actualiza la línea:

```brightscript
jsonUrl = "https://raw.githubusercontent.com/tu-usuario/tu-repositorio/main/trailers.json"
```

Reemplaza:
- `tu-usuario`: Tu nombre de usuario de GitHub
- `tu-repositorio`: Nombre de tu repositorio
- `main`: Rama donde está el archivo (puede ser `master` en repositorios antiguos)

### Ejemplo de URL Real
```brightscript
jsonUrl = "https://raw.githubusercontent.com/johndoe/roku-tmdb-trailers/main/trailers.json"
```

## Cómo Agregar Nuevos Trailers

### 1. Obtener el ID de la Película

- Ve a [TMDB](https://www.themoviedb.org/)
- Busca la película
- El ID está en la URL: `https://www.themoviedb.org/movie/MOVIE_ID-title`

### 2. Obtener URL Directo del Video

**Para URLs directos (Recomendado):**
- Usa servicios de hosting de video que proporcionen URLs directos
- Formatos soportados: HLS (.m3u8), MP4 (.mp4), DASH (.mpd)
- Asegúrate de que el servidor soporte CORS para Roku

**Para YouTube (Alternativo):**
1. Busca el trailer oficial en YouTube
2. Copia la URL completa del video
3. Prefiere trailers en español si están disponibles

### 3. Agregar al JSON

Agrega una nueva entrada en la sección `trailers`:

```json
"MOVIE_ID": {
  "title": "Título de la Película",
  "video_url": "https://ejemplo.com/video.m3u8",
  "language": "es",
  "type": "Trailer",
  "quality": "HD",
  "format": "HLS"
}
### 4. Actualizar Metadatos

- Actualiza `last_updated` con la fecha actual
- Opcionalmente incrementa `version` para cambios mayores

## Funcionamiento del Sistema

### Procesamiento de URLs

El sistema detecta automáticamente el formato del video:
- **HLS (.m3u8)**: Listo para streaming en Roku
- **MP4 (.mp4)**: Reproducción directa en Roku  
- **DASH (.mpd)**: Streaming adaptativo en Roku
- **YouTube**: Marcado para procesamiento especial

### Cache Local

- Los datos se guardan en el registry de Roku por 1 hora
- Reduce la carga de red y mejora la velocidad
- Cache se renueva automáticamente cuando expira

### Sistema de Fallback

1. **Primera opción**: Busca en el archivo JSON externo
2. **Segunda opción**: Si no se encuentra, usa la API de TMDB (español)
3. **Tercera opción**: Si no hay trailer en español, usa API de TMDB (inglés)
4. **Última opción**: Muestra "NOT_FOUND"

### Logs de Debug

El sistema genera logs detallados:

```
Trailer requested for movie ID: 1061474
Found trailer for movie 1061474: https://v1.ecartelera.com/video/35100/35108/playlist.m3u8
  Format: HLS
Processing video URL with format: HLS
Direct video URL detected: https://v1.ecartelera.com/video/35100/35108/playlist.m3u8
```
Using cached trailer data
O en caso de fallback:

```
Trailer not found in external JSON, falling back to TMDB API...
```

## Ventajas del Sistema

1. **URLs Directos**: Reproducción nativa en Roku sin procesamiento adicional
2. **Múltiples Formatos**: Soporte para HLS, MP4, DASH y YouTube
3. **Actualizaciones Fáciles**: Solo edita el archivo JSON en GitHub
4. **Sin Recompilación**: Los cambios se reflejan inmediatamente
5. **Control de Calidad**: Puedes elegir trailers específicos de mejor calidad
6. **Detección Automática**: El sistema detecta el formato del video automáticamente
7. **Multiidioma**: Prioriza trailers en español pero mantiene fallback
8. **Performance**: Sistema de cache reduce llamadas de red
9. **Confiabilidad**: Fallback automático a API de TMDB

## Mejores Prácticas para URLs Directos

### ✅ Recomendaciones
- **Usa HLS (.m3u8)** para mejor adaptabilidad de red
- **Verifica CORS** - El servidor debe permitir requests desde Roku
- **Prueba URLs** antes de agregarlos al JSON
- **Usa HTTPS** siempre que sea posible
- **Calidad HD** (1280x720) es ideal para Roku

### ⚠️ Consideraciones
- **Evita URLs temporales** que expiren rápidamente
- **Verifica la región** - algunos contenidos pueden estar geo-bloqueados
- **Tamaño de archivo** - URLs muy grandes pueden causar buffering
- **Ancho de banda** - Considera la velocidad promedio de usuarios

## Mantenimiento

### Actualización Regular

- Revisa las películas populares cada semana
- Agrega trailers para películas nuevas
- Verifica que los enlaces de YouTube sigan funcionando

### Monitoring

- Revisa los logs de Roku para detectar fallos
- Si muchas películas usan fallback, actualiza el JSON
- Considera aumentar el tiempo de cache si hay problemas de rendimiento

## Troubleshooting

### Error: "Cannot download from GitHub"

- Verifica que la URL sea correcta
- Asegúrate de que el repositorio sea público
- Usa la URL "raw" de GitHub, no la del navegador

### Error: "JSON parse failed"

- Valida el JSON en [jsonlint.com](https://jsonlint.com/)
- Revisa que todas las comillas sean dobles
- Verifica que no falten comas

### Trailers no se encuentran

- Asegúrate de que el MOVIE_ID sea correcto (número como string)
- Verifica que la URL de YouTube sea completa
- Revisa los logs de debug en Roku

## Ejemplo Completo de Workflow

1. **Nueva película popular aparece en TMDB**
2. **Obtener datos**:
   - ID: 912649
   - Título: "Venom: The Last Dance"
   - Buscar trailer en YouTube
3. **Actualizar JSON**:
   ```json
   "912649": {
     "title": "Venom: The Last Dance",
     "youtube_url": "https://www.youtube.com/watch?v=__2bjWbetsA",
     "language": "es",
     "type": "Trailer",
     "quality": "HD"
   }
   ```
4. **Commit y push a GitHub**
5. **La aplicación usará el nuevo trailer en máximo 1 hora**