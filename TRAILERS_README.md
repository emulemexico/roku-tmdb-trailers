# Sistema de Trailers Externos para Roku TMDB App

## Descripción

Este sistema permite mantener las URLs de los trailers de películas en un archivo JSON externo alojado en GitHub, facilitando las actualizaciones sin necesidad de modificar el código de la aplicación Roku.

## Estructura del Archivo JSON

El archivo `trailers.json` debe tener la siguiente estructura:

```json
{
  "version": "1.0",
  "last_updated": "2025-09-22",
  "description": "Archivo de URLs de trailers para películas TMDB",
  "trailers": {
    "MOVIE_ID": {
      "title": "Título de la Película",
      "youtube_url": "https://www.youtube.com/watch?v=VIDEO_ID",
      "language": "es",
      "type": "Trailer",
      "quality": "HD"
    }
  },
  "fallback": {
    "enabled": true,
    "use_tmdb_api": true,
    "description": "Si no se encuentra trailer en este archivo, usar API de TMDB como respaldo"
  }
}
```

### Campos Obligatorios

- **MOVIE_ID**: El ID de la película en TMDB (como string)
- **title**: Título de la película
- **youtube_url**: URL completa del trailer en YouTube
- **language**: Idioma del trailer (es, en, etc.)
- **type**: Tipo de video (Trailer, Teaser, Clip)
- **quality**: Calidad del video (HD, SD)

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

### 2. Encontrar el Trailer en YouTube

1. Busca el trailer oficial en YouTube
2. Copia la URL completa del video
3. Prefiere trailers en español si están disponibles

### 3. Agregar al JSON

Agrega una nueva entrada en la sección `trailers`:

```json
"533535": {
  "title": "Deadpool & Wolverine",
  "youtube_url": "https://www.youtube.com/watch?v=73_1biulkYk",
  "language": "es",
  "type": "Trailer",
  "quality": "HD"
}
```

### 4. Actualizar Metadatos

- Actualiza `last_updated` con la fecha actual
- Opcionalmente incrementa `version` para cambios mayores

## Funcionamiento del Sistema

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
Trailer requested for movie ID: 533535
Using cached trailer data
Found trailer for movie 533535: https://www.youtube.com/watch?v=73_1biulkYk
```

O en caso de fallback:

```
Trailer not found in external JSON, falling back to TMDB API...
```

## Ventajas del Sistema

1. **Actualizaciones Fáciles**: Solo edita el archivo JSON en GitHub
2. **Sin Recompilación**: Los cambios se reflejan inmediatamente
3. **Control de Calidad**: Puedes elegir trailers específicos de mejor calidad
4. **Multiidioma**: Prioriza trailers en español pero mantiene fallback
5. **Performance**: Sistema de cache reduce llamadas de red
6. **Confiabilidad**: Fallback automático a API de TMDB

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