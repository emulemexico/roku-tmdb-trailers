sub init()
    m.posterImage = m.top.findNode("posterImage")
    m.backdropImage = m.top.findNode("backdropImage")
    m.titleLabel = m.top.findNode("titleLabel")
    m.overviewLabel = m.top.findNode("overviewLabel")
    m.releaseDateLabel = m.top.findNode("releaseDateLabel")
    m.ratingLabel = m.top.findNode("ratingLabel")
    
    m.top.observeField("movie", "onMovieChanged")
    m.top.setFocus(true)
end sub

sub onMovieChanged()
    movie = m.top.movie
    if movie <> invalid
        m.titleLabel.text = movie.title
        if movie.overview <> invalid
            m.overviewLabel.text = movie.overview
        else
            m.overviewLabel.text = "Sin descripción disponible"
        end if
        
        if movie.release_date <> invalid
            m.releaseDateLabel.text = "Fecha de estreno: " + movie.release_date
        end if
        
        if movie.vote_average <> invalid
            m.ratingLabel.text = "Calificación: " + str(movie.vote_average) + "/10"
        end if
        
        if movie.HDPosterUrl <> invalid
            m.posterImage.uri = movie.HDPosterUrl
        end if
        
        if movie.backdrop_path <> invalid
            m.backdropImage.uri = "https://image.tmdb.org/t/p/w1920" + movie.backdrop_path
        end if
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press
        if key = "back"
            ' Regresar a la escena principal
            return true
        end if
    end if
    return false
end function