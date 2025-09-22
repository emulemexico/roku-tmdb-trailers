
sub init()
    m.top.observeField("control", "onControlChanged")
end sub

sub onControlChanged()
    if m.top.control = "run" then
        fetchMovies()
    end if
end sub

sub fetchMovies()
    ' Señal de inicio
    m.top.errorMessage = "Iniciando descarga..."
    apiKey = m.top.apiKey
    url = "https://api.themoviedb.org/3/movie/popular?api_key=" + apiKey + "&language=es-ES&page=1"
    
    ' Debug: mostrar URL (sin API key completa por seguridad)
    m.top.errorMessage = "URL preparada, iniciando..."
    
    port = CreateObject("roMessagePort")
    http = CreateObject("roUrlTransfer")
    http.SetUrl(url)
    http.SetCertificatesFile("common:/certs/ca-bundle.crt")
    http.SetPort(port)
    
    if http.AsyncGetToString()
        m.top.errorMessage = "Esperando respuesta..."
        msg = wait(10000, port)
        if type(msg) = "roUrlEvent"
            code = msg.GetResponseCode()
            m.top.errorCode = code
            body = msg.GetString()
            reason = msg.GetFailureReason()
            
            m.top.errorMessage = "HTTP " + code.ToStr() + " recibido"
            
            if code >= 200 and code < 300
                json = ParseJSON(body)
                if json <> invalid and json.results <> invalid and json.results.Count() > 0
                    movies = []
                    itemCount = 10
                    if json.results.Count() < itemCount then itemCount = json.results.Count()
                    for i = 0 to itemCount - 1
                        movie = json.results[i]
                        posterPath = invalid
                        if movie.poster_path <> invalid then posterPath = movie.poster_path
                        posterUrl = invalid
                        if posterPath <> invalid then posterUrl = "https://image.tmdb.org/t/p/w342" + posterPath
                        movies.push({
                            title: movie.title,
                            HDPosterUrl: posterUrl
                        })
                    end for
                    m.top.results = movies
                    m.top.errorMessage = "Recibidos " + itemCount.ToStr() + " items"
                else
                    m.top.results = []
                    m.top.errorMessage = "Sin resultados en respuesta JSON"
                end if
            else
                m.top.results = []
                if reason <> invalid and reason <> "" then
                    m.top.errorMessage = reason
                else
                    m.top.errorMessage = "HTTP " + code.ToStr()
                end if
            end if
        else
            m.top.results = []
            m.top.errorMessage = "Timeout o sin respuesta"
        end if
    else
        m.top.results = []
        m.top.errorMessage = "Fallo al iniciar petición"
    end if
end sub
