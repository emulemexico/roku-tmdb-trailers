
sub init()
    m.movieGrid = m.top.findNode("movieGrid")
    m.statusLabel = m.top.findNode("statusLabel")
    m.selectedMovieLabel = m.top.findNode("selectedMovieLabel")
    m.titleLabel = m.top.findNode("titleLabel")
    
    ' Debug: verificar que los nodos existen
    if m.titleLabel = invalid then
        print "Error: titleLabel no encontrado"
    else
        print "titleLabel encontrado"
        m.titleLabel.text = "Top Ten TMDB"
    end if
    
    if m.selectedMovieLabel = invalid then
        print "Error: selectedMovieLabel no encontrado"
    else
        print "selectedMovieLabel encontrado"
        m.selectedMovieLabel.text = "Selecciona una película"
    end if
    
    m.statusLabel.text = "Cargando datos..."
    
    ' Observar el campo movieData para recibir los datos
    m.top.observeField("movieData", "onMovieDataChanged")
    
    ' Observar resultado de búsqueda de trailer
    m.top.observeField("trailerResult", "onTrailerResultReceived")
    
    ' Configurar el grid para navegación
    m.movieGrid.setFocus(true)
    m.movieGrid.observeField("itemSelected", "onItemSelected")
    m.movieGrid.observeField("itemFocused", "onItemFocused")
    
    ' Inicializar estado de vista de detalles
    m.inDetailsView = false
end sub

sub onItemFocused()
    focusedIndex = m.movieGrid.itemFocused
    if focusedIndex >= 0 and m.moviesArray <> invalid and focusedIndex < m.moviesArray.Count()
        movie = m.moviesArray[focusedIndex]
        m.selectedMovieLabel.text = movie.title
    end if
end sub

sub onItemSelected()
    print "=== GRID SELECTION TRIGGERED ==="
    selectedIndex = m.movieGrid.itemSelected
    print "Item selected index: " + selectedIndex.ToStr()
    print "inDetailsView state: " + m.inDetailsView.ToStr()
    print "moviesArray valid: " + (m.moviesArray <> invalid).ToStr()
    
    if m.moviesArray <> invalid
        print "moviesArray count: " + m.moviesArray.Count().ToStr()
    end if
    
    if selectedIndex >= 0 and m.moviesArray <> invalid and selectedIndex < m.moviesArray.Count()
        movie = m.moviesArray[selectedIndex]
        print "Selected movie title: " + movie.title
        print "Calling showMovieDetailsHere..."
        
        ' Mostrar detalles directamente en esta escena
        showMovieDetailsHere(movie)
        
        print "showMovieDetailsHere completed"
    else
        print "Selection validation failed"
        if selectedIndex < 0 then print "  - selectedIndex is negative"
        if m.moviesArray = invalid then print "  - moviesArray is invalid"
        if m.moviesArray <> invalid and selectedIndex >= m.moviesArray.Count() then print "  - selectedIndex out of bounds"
    end if
    print "=== END GRID SELECTION ==="
end sub

sub showMovieDetailsHere(movie as Object)
    ' Ocultar el grid y labels principales
    m.movieGrid.visible = false
    m.selectedMovieLabel.visible = false
    m.titleLabel.visible = false
    m.statusLabel.visible = false
    
    ' Crear elementos de detalles directamente en esta escena
    createDetailsView(movie)
end sub

sub createDetailsView(movie as Object)
    ' Crear fondo negro
    if m.detailsBackground = invalid
        m.detailsBackground = CreateObject("roSGNode", "Rectangle")
        m.detailsBackground.width = 1920
        m.detailsBackground.height = 1080
        m.detailsBackground.color = "0x000000FF"
        m.top.appendChild(m.detailsBackground)
    end if
    
    ' Crear póster (más pequeño y mejor posicionado)
    if m.detailsPoster = invalid
        m.detailsPoster = CreateObject("roSGNode", "Poster")
        m.detailsPoster.translation = [60, 120]
        m.detailsPoster.width = 180
        m.detailsPoster.height = 270
        m.top.appendChild(m.detailsPoster)
    end if
    
    ' Crear título (ajustado para no salirse)
    if m.detailsTitle = invalid
        m.detailsTitle = CreateObject("roSGNode", "Label")
        m.detailsTitle.translation = [270, 120]
        m.detailsTitle.width = 1200
        m.detailsTitle.height = 50
        m.detailsTitle.font = "font:LargeBoldSystemFont"
        m.detailsTitle.color = "0xFFFFFFFF"
        m.top.appendChild(m.detailsTitle)
    end if
    
    ' Crear fecha de lanzamiento
    if m.detailsReleaseDate = invalid
        m.detailsReleaseDate = CreateObject("roSGNode", "Label")
        m.detailsReleaseDate.translation = [270, 180]
        m.detailsReleaseDate.width = 1200
        m.detailsReleaseDate.height = 35
        m.detailsReleaseDate.font = "font:MediumSystemFont"
        m.detailsReleaseDate.color = "0xCCCCCCFF"
        m.top.appendChild(m.detailsReleaseDate)
    end if
    
    ' Crear calificación
    if m.detailsRating = invalid
        m.detailsRating = CreateObject("roSGNode", "Label")
        m.detailsRating.translation = [270, 220]
        m.detailsRating.width = 1200
        m.detailsRating.height = 35
        m.detailsRating.font = "font:MediumSystemFont"
        m.detailsRating.color = "0xFFD700FF"
        m.top.appendChild(m.detailsRating)
    end if
    
    ' Crear descripción (usando ScrollableText para mejor control)
    if m.detailsOverview = invalid
        m.detailsOverview = CreateObject("roSGNode", "ScrollableText")
        m.detailsOverview.translation = [270, 270]
        m.detailsOverview.width = 1000
        m.detailsOverview.height = 200
        m.detailsOverview.font = "font:SmallSystemFont"
        m.detailsOverview.color = "0xFFFFFFFF"
        m.top.appendChild(m.detailsOverview)
    end if
    
    ' Crear instrucciones (actualizadas para navegación con botón)
    if m.detailsInstructions = invalid
        m.detailsInstructions = CreateObject("roSGNode", "Label")
        m.detailsInstructions.translation = [270, 550]
        m.detailsInstructions.width = 1000
        m.detailsInstructions.height = 35
        m.detailsInstructions.font = "font:MediumSystemFont"
        m.detailsInstructions.color = "0x888888FF"
        m.detailsInstructions.text = "BACK: regresar | ↑↓: navegar | OK: seleccionar trailer/descripción"
        m.top.appendChild(m.detailsInstructions)
    end if
    
    ' Crear botón de trailer estilizado con efecto 3D (sin cornerRadius)
    if m.trailerButton = invalid
        ' Crear un grupo para el botón
        m.trailerButton = CreateObject("roSGNode", "Group")
        m.trailerButton.translation = [270, 490]
        m.trailerButton.focusable = true
        m.trailerButton.visible = false
        m.top.appendChild(m.trailerButton)
        
        ' Sombra del botón (efecto 3D) - usando múltiples rectángulos para simular redondez
        m.trailerButtonShadow = CreateObject("roSGNode", "Rectangle")
        m.trailerButtonShadow.translation = [4, 4]
        m.trailerButtonShadow.width = 220
        m.trailerButtonShadow.height = 60
        m.trailerButtonShadow.color = "0x000000AA"  ' Negro semi-transparente
        m.trailerButton.appendChild(m.trailerButtonShadow)
        
        ' Rectángulos laterales para efecto redondeado de la sombra
        m.trailerButtonShadowL = CreateObject("roSGNode", "Rectangle")
        m.trailerButtonShadowL.translation = [2, 6]
        m.trailerButtonShadowL.width = 2
        m.trailerButtonShadowL.height = 56
        m.trailerButtonShadowL.color = "0x00000088"
        m.trailerButton.appendChild(m.trailerButtonShadowL)
        
        m.trailerButtonShadowR = CreateObject("roSGNode", "Rectangle")
        m.trailerButtonShadowR.translation = [222, 6]
        m.trailerButtonShadowR.width = 2
        m.trailerButtonShadowR.height = 56
        m.trailerButtonShadowR.color = "0x00000088"
        m.trailerButton.appendChild(m.trailerButtonShadowR)
        
        ' Borde del botón (más claro para efecto 3D)
        m.trailerButtonBorder = CreateObject("roSGNode", "Rectangle")
        m.trailerButtonBorder.translation = [0, 0]
        m.trailerButtonBorder.width = 220
        m.trailerButtonBorder.height = 60
        m.trailerButtonBorder.color = "0x666666FF"  ' Gris medio para borde
        m.trailerButton.appendChild(m.trailerButtonBorder)
        
        ' Fondo principal del botón
        m.trailerButtonBg = CreateObject("roSGNode", "Rectangle")
        m.trailerButtonBg.translation = [2, 2]
        m.trailerButtonBg.width = 216
        m.trailerButtonBg.height = 56
        m.trailerButtonBg.color = "0x333333FF"  ' Gris oscuro
        m.trailerButton.appendChild(m.trailerButtonBg)
        
        ' Highlight superior (efecto de brillo)
        m.trailerButtonHighlight = CreateObject("roSGNode", "Rectangle")
        m.trailerButtonHighlight.translation = [2, 2]
        m.trailerButtonHighlight.width = 216
        m.trailerButtonHighlight.height = 20
        m.trailerButtonHighlight.color = "0xFFFFFF33"  ' Blanco semi-transparente
        m.trailerButton.appendChild(m.trailerButtonHighlight)
        
        ' Icono de play (triángulo)
        m.trailerButtonIcon = CreateObject("roSGNode", "Label")
        m.trailerButtonIcon.translation = [15, 15]
        m.trailerButtonIcon.width = 30
        m.trailerButtonIcon.height = 30
        m.trailerButtonIcon.text = "▶"
        m.trailerButtonIcon.font = "font:LargeSystemFont"
        m.trailerButtonIcon.color = "0xFFFFFFFF"
        m.trailerButtonIcon.horizAlign = "center"
        m.trailerButtonIcon.vertAlign = "center"
        m.trailerButton.appendChild(m.trailerButtonIcon)
        
        ' Texto del botón
        m.trailerButtonText = CreateObject("roSGNode", "Label")
        m.trailerButtonText.translation = [50, 15]
        m.trailerButtonText.width = 160
        m.trailerButtonText.height = 30
        m.trailerButtonText.text = "Ver Trailer"
        m.trailerButtonText.font = "font:MediumBoldSystemFont"
        m.trailerButtonText.color = "0xFFFFFFFF"
        m.trailerButtonText.horizAlign = "center"
        m.trailerButtonText.vertAlign = "center"
        m.trailerButton.appendChild(m.trailerButtonText)
        
        ' Observar eventos del grupo
        m.trailerButton.observeField("focusedChild", "onTrailerButtonFocusChanged")
    end if
    
    ' Llenar con datos de la película
    m.detailsTitle.text = movie.title
    
    ' Guardar el ID de la película para buscar el trailer
    m.currentMovieId = invalid
    if movie.DoesExist("id") and movie.id <> invalid
        m.currentMovieId = movie.id
        print "Movie ID found: " + movie.id.ToStr()
    else
        print "No movie ID available for trailer search"
    end if
    
    ' Debug: mostrar qué datos tenemos
    print "=== MOVIE DETAILS DEBUG ==="
    print "Title: " + movie.title
    
    ' Verificar cada campo individualmente
    print "Checking releaseDate field:"
    if movie.DoesExist("releaseDate")
        if movie.releaseDate <> invalid and movie.releaseDate <> ""
            print "  Release date found: " + movie.releaseDate
        else
            print "  Release date exists but is empty/invalid"
        end if
    else
        print "  Release date field does not exist"
    end if
    
    print "Checking voteAverage field:"
    if movie.DoesExist("voteAverage")
        if movie.voteAverage <> invalid
            print "  Vote average found: " + movie.voteAverage.ToStr()
        else
            print "  Vote average exists but is invalid"
        end if
    else
        print "  Vote average field does not exist"
    end if
    
    print "Checking overview field:"
    if movie.DoesExist("overview")
        if movie.overview <> invalid and movie.overview <> ""
            print "  Overview found, length: " + movie.overview.Len().ToStr()
        else
            print "  Overview exists but is empty/invalid"
        end if
    else
        print "  Overview field does not exist"
    end if
    
    if movie.HDPosterUrl <> invalid
        m.detailsPoster.uri = movie.HDPosterUrl
    end if
    
    ' Mostrar fecha de lanzamiento
    if movie.DoesExist("releaseDate") and movie.releaseDate <> invalid and movie.releaseDate <> ""
        m.detailsReleaseDate.text = "Fecha de estreno: " + movie.releaseDate
    else
        m.detailsReleaseDate.text = "Fecha de estreno: No disponible"
    end if
    
    ' Mostrar calificación
    if movie.DoesExist("voteAverage") and movie.voteAverage <> invalid
        rating = movie.voteAverage.ToStr()
        m.detailsRating.text = "★ " + rating + "/10"
    else
        m.detailsRating.text = "★ Sin calificación"
    end if
    
    ' Mostrar descripción (ScrollableText maneja automáticamente el ajuste)
    if movie.DoesExist("overview") and movie.overview <> invalid and movie.overview <> ""
        m.detailsOverview.text = movie.overview
    else
        m.detailsOverview.text = "Sin descripción disponible para esta película."
    end if
    
    ' Mostrar elementos de detalles
    m.detailsBackground.visible = true
    m.detailsPoster.visible = true
    m.detailsTitle.visible = true
    m.detailsReleaseDate.visible = true
    m.detailsRating.visible = true
    m.detailsOverview.visible = true
    m.detailsInstructions.visible = true
    m.trailerButton.visible = true
    
    ' Dar foco al botón de trailer para empezar
    m.trailerButton.setFocus(true)
    onTrailerButtonFocusChanged()  ' Actualizar apariencia inicial
    m.inDetailsView = true
end sub

sub hideDetailsView()
    ' Ocultar elementos de detalles
    if m.detailsBackground <> invalid then m.detailsBackground.visible = false
    if m.detailsPoster <> invalid then m.detailsPoster.visible = false
    if m.detailsTitle <> invalid then m.detailsTitle.visible = false
    if m.detailsReleaseDate <> invalid then m.detailsReleaseDate.visible = false
    if m.detailsRating <> invalid then m.detailsRating.visible = false
    if m.detailsOverview <> invalid then m.detailsOverview.visible = false
    if m.detailsInstructions <> invalid then m.detailsInstructions.visible = false
    if m.trailerButton <> invalid then m.trailerButton.visible = false
    
    ' Mostrar elementos principales
    m.movieGrid.visible = true
    m.selectedMovieLabel.visible = true
    m.titleLabel.visible = true
    m.statusLabel.visible = true
    
    ' Devolver el foco al grid
    m.movieGrid.setFocus(true)
    m.inDetailsView = false
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    ' Solo manejar eventos en vista de detalles
    if press and m.inDetailsView = true
        if key = "back"
            hideDetailsView()
            return true
        else if key = "OK"
            ' Si el botón de trailer tiene foco, ejecutar trailer
            if m.trailerButton.hasFocus()
                onTrailerButtonSelected()
                return true
            end if
        else if key = "up" or key = "down"
            ' Permitir navegación entre botón de trailer y descripción
            if m.trailerButton.hasFocus()
                ' Si el botón tiene foco, ir a la descripción
                m.detailsOverview.setFocus(true)
                onTrailerButtonFocusChanged()  ' Actualizar apariencia
                return true
            else if m.detailsOverview.hasFocus()
                ' Si la descripción tiene foco, ir al botón
                m.trailerButton.setFocus(true)
                onTrailerButtonFocusChanged()  ' Actualizar apariencia
                return true
            end if
        end if
    end if
    return false
end function

sub onTrailerButtonSelected()
    print "Trailer button selected!"
    playMovieTrailer()
end sub

sub onTrailerButtonFocusChanged()
    ' Cambiar apariencia del botón según el foco con efectos 3D mejorados
    if m.trailerButton.hasFocus()
        ' Con foco - efecto presionado y colores vibrantes
        m.trailerButtonShadow.translation = [2, 2]  ' Sombra más cerca (efecto presionado)
        m.trailerButtonShadow.color = "0x000000DD"  ' Sombra más oscura
        m.trailerButtonShadowL.translation = [0, 4]  ' Ajustar laterales
        m.trailerButtonShadowR.translation = [220, 4]
        m.trailerButtonShadowL.color = "0x000000AA"
        m.trailerButtonShadowR.color = "0x000000AA"
        
        m.trailerButtonBorder.color = "0xFF6600FF"  ' Borde naranja brillante
        m.trailerButtonBg.color = "0xFF0000FF"     ' Fondo rojo Netflix
        m.trailerButtonBg.translation = [1, 1]     ' Ligeramente presionado
        
        m.trailerButtonHighlight.color = "0xFFFFFF66"  ' Brillo más intenso
        m.trailerButtonHighlight.height = 25           ' Área de brillo más grande
        
        m.trailerButtonIcon.color = "0xFFFFFFFF"    ' Icono blanco brillante
        m.trailerButtonText.color = "0xFFFFFFFF"    ' Texto blanco brillante
        
        ' Efecto de pulsación suave
        m.trailerButtonIcon.font = "font:LargeBoldSystemFont"
    else
        ' Sin foco - efecto elevado y colores normales
        m.trailerButtonShadow.translation = [4, 4]  ' Sombra más lejos (efecto elevado)
        m.trailerButtonShadow.color = "0x00000088"  ' Sombra más suave
        m.trailerButtonShadowL.translation = [2, 6]  ' Laterales normales
        m.trailerButtonShadowR.translation = [222, 6]
        m.trailerButtonShadowL.color = "0x00000044"
        m.trailerButtonShadowR.color = "0x00000044"
        
        m.trailerButtonBorder.color = "0x666666FF"  ' Borde gris normal
        m.trailerButtonBg.color = "0x333333FF"     ' Fondo gris oscuro
        m.trailerButtonBg.translation = [2, 2]     ' Posición normal
        
        m.trailerButtonHighlight.color = "0xFFFFFF22"  ' Brillo sutil
        m.trailerButtonHighlight.height = 20           ' Área de brillo normal
        
        m.trailerButtonIcon.color = "0xCCCCCCFF"    ' Icono gris claro
        m.trailerButtonText.color = "0xCCCCCCFF"    ' Texto gris claro
        
        ' Tamaño normal del icono
        m.trailerButtonIcon.font = "font:LargeSystemFont"
    end if
end sub

sub playMovieTrailer()
    print "=== TRAILER REQUEST START ==="
    
    if m.currentMovieId <> invalid
        print "Requesting trailer for movie ID: " + m.currentMovieId.ToStr()
        ' Enviar solicitud de trailer al main thread
        m.top.requestTrailer = m.currentMovieId
    else
        print "No movie ID available"
        showMessage("No se puede reproducir trailer: ID de película no disponible")
    end if
    
    print "=== TRAILER REQUEST END ==="
end sub

sub onTrailerResultReceived()
    trailerResult = m.top.trailerResult
    print "Trailer result received: " + trailerResult
    
    if trailerResult <> "" and trailerResult <> "ERROR" and trailerResult <> "NOT_FOUND"
        ' Se encontró un trailer
        youtubeUrl = "https://www.youtube.com/watch?v=" + trailerResult
        message = "Trailer encontrado!" + Chr(10) + Chr(10) + "URL: " + youtubeUrl + Chr(10) + Chr(10) + "Nota: La reproducción directa de YouTube no está disponible en Roku."
        showMessage(message)
    else if trailerResult = "NOT_FOUND"
        showMessage("No se encontró trailer disponible para esta película")
    else if trailerResult = "ERROR"
        showMessage("Error al buscar trailer")
    end if
end sub

sub showMessage(text as String)
    print "Message: " + text
    
    ' Crear mensaje temporal en pantalla
    if m.messageLabel = invalid
        ' Fondo del mensaje
        m.messageBg = CreateObject("roSGNode", "Rectangle")
        m.messageBg.translation = [460, 390]
        m.messageBg.width = 1000
        m.messageBg.height = 300
        m.messageBg.color = "0x000000DD"
        m.top.appendChild(m.messageBg)
        
        m.messageLabel = CreateObject("roSGNode", "Label")
        m.messageLabel.translation = [480, 420]
        m.messageLabel.width = 960
        m.messageLabel.height = 240
        m.messageLabel.font = "font:MediumSystemFont"
        m.messageLabel.color = "0xFFFFFFFF"
        m.messageLabel.horizAlign = "left"
        m.messageLabel.vertAlign = "top"
        m.messageLabel.wrap = true
        m.top.appendChild(m.messageLabel)
    end if
    
    m.messageLabel.text = text
    m.messageLabel.visible = true
    m.messageBg.visible = true
    
    ' Ocultar mensaje después de 5 segundos para mensajes largos
    timer = CreateObject("roSGNode", "Timer")
    timer.duration = 5
    timer.repeat = false
    timer.observeField("fire", "hideMessage")
    timer.control = "start"
    m.messageTimer = timer
end sub

sub hideMessage()
    if m.messageLabel <> invalid
        m.messageLabel.visible = false
        m.messageBg.visible = false
    end if
    if m.messageTimer <> invalid
        m.messageTimer.control = "stop"
        m.messageTimer = invalid
    end if
end sub

sub onMovieDataChanged()
    moviesData = m.top.movieData
    if moviesData <> invalid and moviesData.Count() > 0
        m.statusLabel.text = "Mostrando " + moviesData.Count().ToStr() + " películas..."
        
        ' Guardar los datos COMPLETOS de películas para usar en navegación
        m.moviesArray = moviesData
        
        ' Debug: verificar datos de la primera película
        if moviesData.Count() > 0
            firstMovie = moviesData[0]
            print "First movie data check:"
            print "Title: " + firstMovie.title.ToStr()
            if firstMovie.releaseDate <> invalid
                print "Release Date: " + firstMovie.releaseDate.ToStr()
            else
                print "Release Date: invalid"
            end if
            if firstMovie.voteAverage <> invalid
                print "Vote Average: " + firstMovie.voteAverage.ToStr()
            else
                print "Vote Average: invalid"
            end if
            if firstMovie.overview <> invalid
                print "Overview exists, length: " + firstMovie.overview.Len().ToStr()
            else
                print "Overview: invalid"
            end if
        end if
        
        contentNode = CreateObject("roSGNode", "ContentNode")
        for each movie in moviesData
            item = CreateObject("roSGNode", "ContentNode")
            item.title = movie.title
            if movie.HDPosterUrl <> invalid
                item.HDPosterUrl = movie.HDPosterUrl
            end if
            contentNode.appendChild(item)
        end for
        
        m.movieGrid.content = contentNode
        m.statusLabel.text = ""
        
        ' Mostrar el título de la primera película
        if m.moviesArray.Count() > 0
            m.selectedMovieLabel.text = m.moviesArray[0].title
        end if
    else
        m.statusLabel.text = "Sin películas para mostrar"
    end if
end sub