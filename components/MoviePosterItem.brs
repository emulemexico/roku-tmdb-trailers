sub init()
    m.poster = m.top.findNode("poster")
    m.titleLabel = m.top.findNode("titleLabel")
    m.top.observeField("content", "onContentChanged")
end sub

sub onContentChanged()
    content = m.top.content
    if content <> invalid
        m.poster.uri = content.HDPosterUrl
        m.titleLabel.text = content.title
    end if
end sub
