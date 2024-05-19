class Shared::EmbeddedVideoComponent < ApplicationComponent
  attr_reader :record

  def initialize(record)
    @record = record
  end

  def render?
    record.video_url.present?
  end

  def embedded_video_code
    link = record.video_url
    title = t("proposals.show.embed_video_title", proposal: record.title)
    if link =~ /vimeo.*/
      server = "Vimeo"
    elsif link =~ /youtu*.*/
      server = "YouTube"
    end

    if server == "Vimeo"
      reg_exp = record.class::VIMEO_REGEX
      src = "https://player.vimeo.com/video/"
    elsif server == "YouTube"
      reg_exp = record.class::YOUTUBE_REGEX
      src = "https://www.youtube.com/embed/"
    end

    if reg_exp
      match = link.match(reg_exp)
    end

    if match && match[2]
      '<iframe src="' + src + match[2] + '" style="border:0;" allowfullscreen title="' + title + '"></iframe>'
    else
      ""
    end
  end
end
