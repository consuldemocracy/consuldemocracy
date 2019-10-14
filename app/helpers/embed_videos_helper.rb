module EmbedVideosHelper

  def embedded_video_code
    link = @proposal.video_url
    title = t('proposals.show.embed_video_title', proposal: @proposal.title)
    if link.match(/vimeo.*/)
      server = "Vimeo"
    elsif link.match(/youtu*.*/)
      server = "YouTube"
    end

    if server == "Vimeo"
      reg_exp = /vimeo.*(staffpicks\/|channels\/|videos\/|video\/|\/)([^#\&\?]*).*/
      src =  "https://player.vimeo.com/video/"
    elsif server == "YouTube"
      reg_exp = /youtu.*(be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/
      src = "https://www.youtube.com/embed/"
    end

    if reg_exp
      match = link.match(reg_exp)
    end

    if match and match[2]
      '<iframe src="' + src + match[2] + '" style="border:0;" allowfullscreen title="' + title + '"></iframe>'
    else
      ''
    end
  end

end