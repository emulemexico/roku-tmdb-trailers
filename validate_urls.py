#!/usr/bin/env python3
"""
Script para validar URLs de trailers para Roku
Verifica accesibilidad, CORS, y formato de URLs directos
"""

import requests
import json
import sys
from urllib.parse import urlparse

def validate_url(url, timeout=10):
    """Valida una URL de video para compatibilidad con Roku"""
    result = {
        "url": url,
        "status": "unknown",
        "accessible": False,
        "cors_enabled": False,
        "content_type": "",
        "size": "",
        "format_detected": "",
        "roku_compatible": False
    }
    
    try:
        # Hacer HEAD request para verificar accesibilidad
        headers = {
            'User-Agent': 'Roku/DVP-9.4 (704.9E.00E)',
            'Origin': 'roku'
        }
        
        response = requests.head(url, headers=headers, timeout=timeout, allow_redirects=True)
        result["status"] = response.status_code
        result["accessible"] = response.status_code == 200
        
        # Verificar headers
        result["content_type"] = response.headers.get("content-type", "")
        result["size"] = response.headers.get("content-length", "unknown")
        
        # Verificar CORS
        cors_header = response.headers.get("access-control-allow-origin", "")
        result["cors_enabled"] = cors_header == "*" or "roku" in cors_header.lower()
        
        # Detectar formato
        if url.endswith('.m3u8'):
            result["format_detected"] = "HLS"
        elif url.endswith('.mp4'):
            result["format_detected"] = "MP4"
        elif url.endswith('.mpd'):
            result["format_detected"] = "DASH"
        elif "youtube.com" in url or "youtu.be" in url:
            result["format_detected"] = "YOUTUBE"
        else:
            result["format_detected"] = "UNKNOWN"
        
        # Determinar compatibilidad con Roku
        compatible_types = ["video/mp4", "application/x-mpegURL", "application/dash+xml"]
        result["roku_compatible"] = (
            result["accessible"] and
            (any(ct in result["content_type"] for ct in compatible_types) or 
             result["format_detected"] in ["MP4", "HLS", "DASH"])
        )
        
    except requests.RequestException as e:
        result["error"] = str(e)
    
    return result

def validate_trailers_json(json_file):
    """Valida todas las URLs en el archivo trailers.json"""
    try:
        with open(json_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        print(f"📋 Validando URLs en {json_file}")
        print(f"📊 Versión del JSON: {data.get('version', 'N/A')}")
        print("=" * 80)
        
        results = []
        trailers = data.get('trailers', {})
        
        for movie_id, trailer_info in trailers.items():
            print(f"\n🎬 {trailer_info.get('title', 'Sin título')} (ID: {movie_id})")
            
            url = trailer_info.get('video_url', '')
            if not url:
                print("   ❌ No hay URL de video")
                continue
                
            print(f"   🔗 URL: {url}")
            
            # Validar URL
            result = validate_url(url)
            results.append({
                "movie_id": movie_id,
                "title": trailer_info.get('title', ''),
                "validation": result
            })
            
            # Mostrar resultados
            if result["accessible"]:
                print(f"   ✅ Accesible (Status: {result['status']})")
            else:
                print(f"   ❌ No accesible (Status: {result['status']})")
            
            if result.get("error"):
                print(f"   ⚠️  Error: {result['error']}")
            
            print(f"   📁 Formato: {result['format_detected']}")
            print(f"   📝 Content-Type: {result['content_type']}")
            
            if result["cors_enabled"]:
                print("   ✅ CORS habilitado")
            else:
                print("   ⚠️  CORS no detectado")
            
            if result["roku_compatible"]:
                print("   ✅ Compatible con Roku")
            else:
                print("   ❌ Puede no ser compatible con Roku")
        
        # Resumen
        print("\n" + "=" * 80)
        print("📊 RESUMEN DE VALIDACIÓN")
        print("=" * 80)
        
        total = len(results)
        accessible = sum(1 for r in results if r["validation"]["accessible"])
        roku_compatible = sum(1 for r in results if r["validation"]["roku_compatible"])
        cors_enabled = sum(1 for r in results if r["validation"]["cors_enabled"])
        
        print(f"Total de URLs: {total}")
        print(f"URLs accesibles: {accessible}/{total} ({accessible/total*100:.1f}%)")
        print(f"Compatible con Roku: {roku_compatible}/{total} ({roku_compatible/total*100:.1f}%)")
        print(f"Con CORS habilitado: {cors_enabled}/{total} ({cors_enabled/total*100:.1f}%)")
        
        # URLs problemáticas
        problematic = [r for r in results if not r["validation"]["roku_compatible"]]
        if problematic:
            print(f"\n⚠️  URLs problemáticas ({len(problematic)}):")
            for item in problematic:
                print(f"   - {item['title']} (ID: {item['movie_id']})")
        
        return results
        
    except FileNotFoundError:
        print(f"❌ Archivo no encontrado: {json_file}")
        return []
    except json.JSONDecodeError as e:
        print(f"❌ Error en JSON: {e}")
        return []

def main():
    if len(sys.argv) > 1:
        json_file = sys.argv[1]
    else:
        json_file = "trailers.json"
    
    print("🎬 VALIDADOR DE URLs DE TRAILERS PARA ROKU")
    print("=" * 80)
    
    results = validate_trailers_json(json_file)
    
    if results:
        print(f"\n💾 Resultados guardados en validation_results.json")
        with open("validation_results.json", 'w', encoding='utf-8') as f:
            json.dump(results, f, indent=2, ensure_ascii=False)

if __name__ == "__main__":
    main()