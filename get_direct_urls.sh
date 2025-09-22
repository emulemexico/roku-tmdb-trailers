#!/bin/bash
# Script para obtener URLs directos usando yt-dlp
# Uso: ./get_direct_urls.sh [URL_YOUTUBE]

echo "🎬 EXTRACTOR DE URLs DIRECTOS PARA ROKU"
echo "======================================"

# Verificar si yt-dlp está instalado
if ! command -v yt-dlp &> /dev/null; then
    echo "❌ yt-dlp no está instalado"
    echo "💡 Instalar con: pip install yt-dlp"
    exit 1
fi

if [ -z "$1" ]; then
    echo "❌ Uso: $0 [URL_YOUTUBE]"
    echo "📝 Ejemplo: $0 'https://www.youtube.com/watch?v=73_1biulkYk'"
    exit 1
fi

URL="$1"
echo "🔗 Procesando: $URL"
echo ""

echo "📊 Obteniendo información del video..."
yt-dlp --print "title:%(title)s" --print "duration:%(duration)s seconds" "$URL"
echo ""

echo "🎥 Formatos disponibles:"
yt-dlp -F "$URL" | grep -E "(mp4|m3u8|webm)" | head -10
echo ""

echo "🎯 Obteniendo URL directo (mejor calidad MP4)..."
DIRECT_URL=$(yt-dlp -f "best[ext=mp4][height<=720]" --get-url "$URL" 2>/dev/null)

if [ -n "$DIRECT_URL" ]; then
    echo "✅ URL directo obtenido:"
    echo "$DIRECT_URL"
    echo ""
    
    echo "📋 JSON para tu archivo trailers.json:"
    echo '"MOVIE_ID": {'
    echo '  "title": "TITULO_PELICULA",'
    echo "  \"video_url\": \"$DIRECT_URL\","
    echo '  "language": "es",'
    echo '  "type": "Trailer",'
    echo '  "quality": "HD",'
    echo '  "format": "MP4"'
    echo '}'
    echo ""
    
    echo "🧪 Probando URL..."
    if curl -s --head "$DIRECT_URL" | head -n 1 | grep -q "200 OK"; then
        echo "✅ URL funcional"
    else
        echo "⚠️  URL puede ser temporal o requerir headers especiales"
    fi
else
    echo "❌ No se pudo obtener URL directo"
    echo "💡 Intenta con otro video o formato"
fi

echo ""
echo "⚠️  NOTA: URLs de YouTube pueden ser temporales"
echo "💡 Para URLs permanentes, considera usar servicios de hosting dedicados"