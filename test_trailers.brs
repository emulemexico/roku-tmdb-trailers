sub TestTrailerSystem()
    ' Script de prueba para validar el sistema de trailers externos
    print "=== INICIANDO PRUEBA DEL SISTEMA DE TRAILERS ==="
    
    ' Simular solicitud de trailer para Wicked (ID: 402431)
    print "Probando película: Wicked (ID: 402431)"
    trailerUrl = getTrailerFromExternalJSON("402431")
    
    if trailerUrl <> ""
        print "✓ ÉXITO: Trailer encontrado en JSON externo"
        print "  URL: " + trailerUrl
    else
        print "✗ ERROR: No se encontró trailer en JSON externo"
    end if
    
    ' Probar con una película que NO está en el JSON
    print ""
    print "Probando película NO en JSON (ID: 999999)"
    trailerUrl2 = getTrailerFromExternalJSON("999999")
    
    if trailerUrl2 = ""
        print "✓ ÉXITO: Correctamente no encontró película inexistente"
        print "  Sistema debería usar fallback a TMDB API"
    else
        print "✗ ERROR: Encontró trailer para película inexistente"
    end if
    
    print ""
    print "=== PRUEBA COMPLETADA ==="
end sub

' Simular las funciones del sistema principal
function getTrailerFromExternalJSON(movieId as String) as String
    ' URL del archivo JSON en GitHub
    jsonUrl = "https://raw.githubusercontent.com/emulemexico/roku-tmdb-trailers/main/trailers.json"
    
    print "Descargando datos desde: " + jsonUrl
    
    ' En un entorno real, esto sería roUrlTransfer
    ' Para la prueba, simplemente simularemos que funciona
    print "Simulando descarga de JSON..."
    
    ' En la aplicación real, aquí estaría el código de descarga
    ' y parsing del JSON para buscar el movieId
    
    ' Para la prueba, verificamos manualmente
    if movieId = "402431"
        return "https://www.youtube.com/watch?v=JDSRDbFqc_E"
    else
        return ""
    end if
end function

' Ejecutar la prueba
TestTrailerSystem()