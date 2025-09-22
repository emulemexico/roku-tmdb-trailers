sub Main()
    m.screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    m.screen.setMessagePort(m.port)
    
    m.mainScene = m.screen.CreateScene("MainScene")
    m.screen.Show()
    
    ' Hacer la carga de datos inmediatamente después de mostrar la escena
    loadMoviesFromAPI(m.mainScene)
    
    ' Observar solicitudes de trailer una vez que la escena esté activa
    m.trailerObserverSet = false
    
    while(true)
        msg = wait(0, m.port)
        if type(msg) = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        else if type(msg) = "roSGNodeEvent"
            ' Configurar observer de trailer en el primer evento (escena activa)
            if not m.trailerObserverSet
                m.mainScene.observeField("requestTrailer", "onTrailerRequested")
                m.trailerObserverSet = true
                print "Trailer observer set up"
            end if
            
            if msg.getField() = "showDetails" and msg.getNode().showDetails = true
                showMovieDetails()
                ' Resetear la señal
                m.mainScene.showDetails = false
            else if msg.getField() = "requestTrailer"
                onTrailerRequested()
            end if
        end if
    end while
end sub

sub showMovieDetails()
    selectedMovie = m.mainScene.selectedMovie
    if selectedMovie <> invalid
        ' Crear escena de detalles
        detailsScene = m.screen.CreateScene("MovieDetailsScene")
        detailsScene.movie = selectedMovie
        
        ' Cambiar a la escena de detalles
        m.screen.swapScene(detailsScene)
        
        ' Esperar input del usuario
        while(true)
            msg = wait(0, m.port)
            if type(msg) = "roSGScreenEvent"
                if msg.isScreenClosed() then return
            else if type(msg) = "roInputEvent"
                if msg.isInput()
                    info = msg.GetInfo()
                    if info.DoesExist("buttonPressed") and info.buttonPressed = "back"
                        ' Regresar a la escena principal
                        m.screen.swapScene(m.mainScene)
                        exit while
                    end if
                end if
            end if
        end while
    end if
end sub

sub loadMoviesFromAPI(scene as Object)
    apiKey = "034f6a2f4ac3b8d5ea2743a9d9c4e40b"
    url = "https://api.themoviedb.org/3/movie/popular?api_key=" + apiKey + "&language=es-ES&page=1"
    
    request = CreateObject("roUrlTransfer")
    request.SetUrl(url)
    request.SetCertificatesFile("common:/certs/ca-bundle.crt")
    
    response = request.GetToString()
    if response <> ""
        json = ParseJSON(response)
        if json <> invalid and json.results <> invalid and json.results.Count() > 0
            movies = []
            itemCount = 10
            if json.results.Count() < itemCount then itemCount = json.results.Count()
            
            for i = 0 to itemCount - 1
                movie = json.results[i]
                movieData = {
                    id: movie.id,
                    title: movie.title,
                    overview: movie.overview,
                    releaseDate: movie.release_date,
                    voteAverage: movie.vote_average,
                    backdrop_path: movie.backdrop_path,
                    HDPosterUrl: invalid
                }
                
                if movie.poster_path <> invalid
                    movieData.HDPosterUrl = "https://image.tmdb.org/t/p/w342" + movie.poster_path
                end if
                
                ' Debug: mostrar datos de cada película
                print "Movie " + i.ToStr() + ":"
                print "  ID: " + movie.id.ToStr()
                print "  Title: " + movie.title
                if movie.overview <> invalid
                    print "  Overview length: " + movie.overview.Len().ToStr()
                else
                    print "  Overview: invalid"
                end if
                if movie.release_date <> invalid
                    print "  Release date: " + movie.release_date
                else
                    print "  Release date: invalid"
                end if
                if movie.vote_average <> invalid
                    print "  Vote average: " + movie.vote_average.ToStr()
                else
                    print "  Vote average: invalid"
                end if
                
                movies.push(movieData)
            end for
            
            ' Debug: agregar datos de prueba a la primera película por si acaso
            if movies.Count() > 0
                testMovie = movies[0]
                if testMovie.overview = invalid or testMovie.overview = ""
                    testMovie.overview = "Esta es una descripción de prueba para verificar que el sistema funciona correctamente."
                end if
                if testMovie.releaseDate = invalid or testMovie.releaseDate = ""
                    testMovie.releaseDate = "2024-01-15"
                end if
                if testMovie.voteAverage = invalid
                    testMovie.voteAverage = 8.5
                end if
                movies[0] = testMovie
                print "Test movie data added to first movie"
            end if
            
            ' Agregar películas de prueba con URLs directos funcionales
            demoMovie1 = {
                id: 999991,
                title: "🎬 DEMO: Big Buck Bunny (HLS)",
                overview: "Video de demostración con URL directo HLS para probar el sistema de trailers. Este video utiliza HTTP Live Streaming (.m3u8) que es ideal para Roku.",
                releaseDate: "2024-01-01",
                voteAverage: 9.0,
                backdrop_path: invalid,
                HDPosterUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg"
            }
            
            demoMovie2 = {
                id: 999992,
                title: "🎥 DEMO: Sample Video (MP4)",
                overview: "Video de demostración con URL directo MP4 para probar el sistema de trailers. Este video utiliza formato MP4 directo compatible con Roku.",
                releaseDate: "2024-01-01",
                voteAverage: 8.8,
                backdrop_path: invalid,
                HDPosterUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ElephantsDream.jpg"
            }
            
            ' Insertar las películas demo al principio de la lista
            movies.unshift(demoMovie2)
            movies.unshift(demoMovie1)
            
            print "Added 2 demo movies with direct URLs for testing"
            
            ' Enviar los datos de vuelta a la escena
            scene.movieData = movies
        else
            ' En caso de error, enviar array vacío
            scene.movieData = []
        end if
    else
        ' En caso de error, enviar array vacío
        scene.movieData = []
    end if
end sub

sub onTrailerRequested()
    movieId = m.mainScene.requestTrailer
    print "Trailer requested for movie ID: " + movieId.ToStr()
    
    ' Primero intentar cargar desde archivo JSON externo
    trailerUrl = getTrailerFromExternalJSON(movieId.ToStr())
    
    if trailerUrl <> ""
        print "Found trailer in external JSON: " + trailerUrl
        m.mainScene.trailerResult = trailerUrl
        return
    end if
    
    ' Si no se encuentra en JSON externo, usar API de TMDB como respaldo
    print "Trailer not found in external JSON, falling back to TMDB API..."
    
    apiKey = "034f6a2f4ac3b8d5ea2743a9d9c4e40b"
    
    ' Primero intentar en español
    url = "https://api.themoviedb.org/3/movie/" + movieId.ToStr() + "/videos?api_key=" + apiKey + "&language=es-ES"
    trailerKey = searchTrailerInLanguage(url)
    
    if trailerKey = ""
        ' Si no se encuentra en español, intentar en inglés
        print "No Spanish trailer found, trying English..."
        url = "https://api.themoviedb.org/3/movie/" + movieId.ToStr() + "/videos?api_key=" + apiKey + "&language=en-US"
        trailerKey = searchTrailerInLanguage(url)
    end if
    
    ' Enviar resultado de vuelta a MainScene
    if trailerKey <> ""
        m.mainScene.trailerResult = trailerKey
    else
        m.mainScene.trailerResult = "NOT_FOUND"
    end if
end sub

function searchTrailerInLanguage(url as String) as String
    print "Searching trailer at: " + url
    
    request = CreateObject("roUrlTransfer")
    request.SetUrl(url)
    request.SetCertificatesFile("common:/certs/ca-bundle.crt")
    
    response = request.GetToString()
    if response <> ""
        json = ParseJSON(response)
        if json <> invalid and json.results <> invalid and json.results.Count() > 0
            print "Found " + json.results.Count().ToStr() + " videos"
            return findBestTrailerKey(json.results)
        end if
    end if
    
    return ""
end function

function findBestTrailerKey(videos as Object) as String
    ' Buscar el mejor trailer disponible
    ' Prioridad: Trailer > Teaser > Clip
    
    trailerKey = ""
    teaserKey = ""
    clipKey = ""
    
    for each video in videos
        if video.site = "YouTube"
            if video.type = "Trailer" and trailerKey = ""
                trailerKey = video.key
            else if video.type = "Teaser" and teaserKey = ""
                teaserKey = video.key
            else if video.type = "Clip" and clipKey = ""
                clipKey = video.key
            end if
        end if
    end for
    
    ' Devolver el mejor disponible
    if trailerKey <> ""
        print "Found Trailer: " + trailerKey
        return trailerKey
    else if teaserKey <> ""
        print "Found Teaser: " + teaserKey
        return teaserKey
    else if clipKey <> ""
        print "Found Clip: " + clipKey
        return clipKey
    end if
    
    return ""
end function

' Función para obtener trailer desde archivo JSON externo
function getTrailerFromExternalJSON(movieId as String) as String
    ' URL del archivo JSON en GitHub (raw)
    jsonUrl = "https://raw.githubusercontent.com/emulemexico/roku-tmdb-trailers/main/trailers.json"
    
    ' Intentar cargar desde cache local primero
    cachedData = getCachedTrailerData()
    if cachedData <> invalid
        trailerUrl = extractTrailerFromData(cachedData, movieId)
        if trailerUrl <> ""
            return trailerUrl
        end if
    end if
    
    ' Si no hay cache válido, descargar desde GitHub
    print "Downloading trailer data from: " + jsonUrl
    
    request = CreateObject("roUrlTransfer")
    request.SetUrl(jsonUrl)
    request.SetCertificatesFile("common:/certs/ca-bundle.crt")
    
    response = request.GetToString()
    if response <> ""
        json = ParseJSON(response)
        if json <> invalid and json.trailers <> invalid
            ' Guardar en cache
            saveTrailerDataToCache(response)
            
            ' Buscar el trailer para la película específica
            return extractTrailerFromData(json, movieId)
        end if
    end if
    
    return ""
end function

' Función para extraer URL del trailer desde los datos JSON
function extractTrailerFromData(jsonData as Object, movieId as String) as String
    if jsonData <> invalid and jsonData.trailers <> invalid
        if jsonData.trailers.DoesExist(movieId)
            trailerInfo = jsonData.trailers[movieId]
            if trailerInfo <> invalid and trailerInfo.video_url <> invalid
                print "Found trailer for movie " + movieId + ": " + trailerInfo.video_url
                
                ' Obtener formato si está disponible
                format = ""
                if trailerInfo.format <> invalid
                    format = trailerInfo.format
                    print "  Format: " + format
                end if
                
                ' Procesar la URL según su formato
                processedUrl = processVideoUrl(trailerInfo.video_url, format)
                return processedUrl
            end if
        end if
    end if
    return ""
end function

' Función para obtener datos de trailer desde cache local
function getCachedTrailerData() as Object
    ' Verificar si existe un archivo de cache y si no es muy antiguo
    section = CreateObject("roRegistrySection", "trailers_cache")
    
    cachedJson = section.Read("trailer_data")
    cacheTime = section.Read("cache_time")
    
    if cachedJson <> invalid and cacheTime <> invalid
        ' Verificar si el cache no es muy antiguo (1 hora = 3600 segundos)
        currentTime = CreateObject("roDateTime").AsSeconds()
        if currentTime.ToInt() - cacheTime.ToInt() < 3600
            print "Using cached trailer data"
            return ParseJSON(cachedJson)
        else
            print "Cache expired, will download fresh data"
        end if
    end if
    
    return invalid
end function

' Función para guardar datos de trailer en cache local
sub saveTrailerDataToCache(jsonString as String)
    section = CreateObject("roRegistrySection", "trailers_cache")
    
    currentTime = CreateObject("roDateTime").AsSeconds()
    
    section.Write("trailer_data", jsonString)
    section.Write("cache_time", currentTime.ToStr())
    section.Flush()
    
    print "Trailer data cached successfully"
end sub

' Función para detectar y procesar el formato de video
function processVideoUrl(videoUrl as String, format as String) as String
    if videoUrl = ""
        return ""
    end if
    
    ' Si no se especifica formato, intentar detectarlo desde la URL
    if format = invalid or format = ""
        if videoUrl.InStr(".m3u8") > -1
            format = "HLS"
        else if videoUrl.InStr(".mp4") > -1
            format = "MP4"
        else if videoUrl.InStr("youtube.com") > -1 or videoUrl.InStr("youtu.be") > -1
            format = "YOUTUBE"
        else if videoUrl.InStr(".mpd") > -1
            format = "DASH"
        else
            format = "UNKNOWN"
        end if
    end if
    
    print "Processing video URL with format: " + format
    
    ' Manejar diferentes formatos
    if format = "HLS" or format = "MP4" or format = "DASH"
        ' URLs directos de video - listos para reproducir en Roku
        print "Direct video URL detected: " + videoUrl
        return videoUrl
    else if format = "YOUTUBE"
        ' URLs de YouTube - mostrar URL para referencia (Roku no puede reproducir YouTube directamente)
        print "YouTube URL detected: " + videoUrl
        return videoUrl + " (YouTube URL - Requires external player)"
    else
        ' Formato desconocido - intentar como URL directo
        print "Unknown format, treating as direct URL: " + videoUrl
        return videoUrl
    end if
end function