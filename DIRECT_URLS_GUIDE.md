# Guía para Obtener URLs Directos de Trailers

## Fuentes Recomendadas para URLs Directos

### 🎯 Sitios Confiables (Con URLs Directos)

#### 1. **Archive.org (Internet Archive)**
- **URL Base**: `https://archive.org/`
- **Formato**: MP4, diversos formatos
- **Ventajas**: Gratuito, estable, gran archivo
- **Ejemplo**: `https://archive.org/download/[ID]/[filename].mp4`

#### 2. **Vimeo (URLs directos)**
- **Método**: Inspeccionar elemento en video de Vimeo
- **Formato**: MP4 de alta calidad
- **Ventajas**: Buena calidad, estable
- **Proceso**: F12 → Network → Buscar .mp4

#### 3. **Dailymotion (URLs directos)**
- **Método**: Similar a Vimeo
- **Formato**: MP4, M3U8
- **Ventajas**: Disponibilidad internacional

### 🛠️ Herramientas para Extraer URLs

#### 1. **yt-dlp (Recomendado)**
```bash
# Instalar
pip install yt-dlp

# Obtener URL directo
yt-dlp -f best --get-url [URL_YOUTUBE]

# Obtener formato específico
yt-dlp -f "best[ext=mp4]" --get-url [URL_YOUTUBE]
```

#### 2. **FFmpeg (Para convertir)**
```bash
# Convertir a HLS
ffmpeg -i input.mp4 -c copy -f hls -hls_time 10 -hls_list_size 0 output.m3u8

# Optimizar para Roku
ffmpeg -i input.mp4 -c:v libx264 -c:a aac -b:v 2M -b:a 128k output.mp4
```

## URLs de Ejemplo Funcionales

### 🎬 Trailers de Dominio Público
```json
{
  "public_domain_examples": {
    "12345": {
      "title": "Big Buck Bunny (Ejemplo)",
      "video_url": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
      "language": "en",
      "type": "Demo",
      "quality": "HD",
      "format": "MP4"
    }
  }
}
```

### 🔄 URLs de Prueba Temporales
Estos son para probar el sistema:

```json
{
  "test_urls": {
    "hls_test": "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8",
    "mp4_test": "https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4",
    "dash_test": "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.mpd"
  }
}
```

## Proceso Recomendado

### Paso 1: Usar yt-dlp para YouTube
```bash
# Para Deadpool & Wolverine
yt-dlp -f "best[height<=720]" --get-url "https://www.youtube.com/watch?v=73_1biulkYk"
```

### Paso 2: Verificar URL
```bash
# Probar con curl
curl -I [URL_DIRECTO]

# Verificar headers CORS
curl -H "Origin: roku" -I [URL_DIRECTO]
```

### Paso 3: Agregar al JSON
```json
"533535": {
  "title": "Deadpool & Wolverine",
  "video_url": "[URL_DIRECTO_OBTENIDO]",
  "language": "es",
  "type": "Trailer",
  "quality": "HD",
  "format": "MP4"
}
```

## Consideraciones Importantes

### ✅ URLs Válidos
- Respondan a HEAD requests
- Tengan headers CORS apropiados
- No requieran autenticación especial
- Sean estables (no temporales)

### ❌ URLs Problemáticos
- Con tokens de expiración
- Que requieran cookies/sesiones
- Geo-bloqueados
- Con rate limiting agresivo

### 🔧 Headers Requeridos para Roku
```
Access-Control-Allow-Origin: *
Content-Type: video/mp4 (o application/x-mpegURL para HLS)
Content-Length: [tamaño]
```

## Script de Validación

### Crear validate_urls.py
```python
import requests
import json

def validate_url(url):
    try:
        response = requests.head(url, timeout=10)
        return {
            "status": response.status_code,
            "content_type": response.headers.get("content-type", ""),
            "cors": response.headers.get("access-control-allow-origin", ""),
            "size": response.headers.get("content-length", "")
        }
    except Exception as e:
        return {"error": str(e)}

# Uso
url = "https://ejemplo.com/video.mp4"
result = validate_url(url)
print(json.dumps(result, indent=2))
```

## Hosting Propio (Opción Avanzada)

### Usando GitHub Pages + CDN
1. Sube videos a un CDN (CloudFlare, AWS CloudFront)
2. Configura CORS apropiadamente
3. Usa URLs estables en tu JSON

### Usando Servicios Gratuitos
- **Internet Archive**: Permanent hosting
- **GitHub Releases**: Para archivos grandes
- **Firebase Storage**: Con configuración CORS

## Próximos Pasos Recomendados

1. **Instalar yt-dlp** para extraer URLs de YouTube
2. **Probar URLs** antes de agregarlos al JSON
3. **Validar CORS** para compatibilidad con Roku
4. **Usar servicios estables** para hosting a largo plazo