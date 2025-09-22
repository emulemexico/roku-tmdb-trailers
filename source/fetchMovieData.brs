function GetMovieDataSync()
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
                    title: movie.title,
                    HDPosterUrl: invalid,
                    overview: invalid,
                    releaseDate: invalid,
                    voteAverage: invalid
                }
                
                if movie.poster_path <> invalid
                    movieData.HDPosterUrl = "https://image.tmdb.org/t/p/w342" + movie.poster_path
                end if
                
                if movie.overview <> invalid
                    movieData.overview = movie.overview
                end if
                
                if movie.release_date <> invalid
                    movieData.releaseDate = movie.release_date
                end if
                
                if movie.vote_average <> invalid
                    movieData.voteAverage = movie.vote_average
                end if
                
                movies.push(movieData)
            end for
            
            return {
                movies: movies,
                error: invalid
            }
        else
            return {
                movies: invalid,
                error: "Sin resultados en la respuesta JSON"
            }
        end if
    else
        return {
            movies: invalid,
            error: "Error al descargar datos de TMDB"
        }
    end if
end function