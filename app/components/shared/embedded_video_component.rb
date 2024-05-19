class Shared::EmbeddedVideoComponent < ApplicationComponent
  attr_reader :record

  def initialize(record)
    @record = record
  end

  def render?
    record.video_url.present?
  end

  def embedded_video_code
    if match && match[2]
      "<iframe #{iframe_attributes}></iframe>"
    end
  end

  private

    def link
      record.video_url
    end

    def title
      t("proposals.show.embed_video_title", proposal: record.title)
    end

    def server
      if link =~ /vimeo.*/
        "Vimeo"
      elsif link =~ /youtu*.*/
        "YouTube"
      end
    end

    def regex
      if server == "Vimeo"
        record.class::VIMEO_REGEX
      elsif server == "YouTube"
        record.class::YOUTUBE_REGEX
      end
    end

    def src
      if server == "Vimeo"
        "https://player.vimeo.com/video/"
      elsif server == "YouTube"
        "https://www.youtube-nocookie.com/embed/"
      end
    end

    def match
      @match ||= link.match(regex) if regex
    end

    def iframe_attributes
      tag.attributes(src: "#{src}#{match[2]}", style: "border:0;", allowfullscreen: true, title: title)
    end
end
