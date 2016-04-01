module EmbedVideosHelper

  def embedded_video_code
    link = @proposal.video_url 
    if link.match(/vimeo.*/)
      server = "Vimeo"
    elsif link.match(/youtu*.*/)
      server = "YouTube"
    end  
    
    if server == "Vimeo"
      regExp = /vimeo.*(staffpicks\/|channels\/|videos\/|video\/|\/)([^#\&\?]*).*/
      src =  "https://player.vimeo.com/video/"
    elsif server == "YouTube"
      regExp = /youtu.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/
      src = "https://www.youtube.com/embed/"    
    end
    
    if regExp 
      match  = link.match(regExp)
    end

    if match and match[2]
      '<iframe src="' + src + match[2] + '" frameborder="0" allowfullscreen></iframe>'
    else 
      ''
    end
  end 

end