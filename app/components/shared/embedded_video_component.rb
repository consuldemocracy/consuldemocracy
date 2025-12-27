class Shared::EmbeddedVideoComponent < ApplicationComponent
  attr_reader :record

  def initialize(record)
    @record = record
  end

  def render?
    record.video_url.present?
  end

  def embedded_video_code
    <<-HTML.html_safe
      <div class="video-placeholder" data-src="#{src}" data-title="#{title}">
        <p class="video-warning">
          #{t("valuation.iframe.two_clicks_for_iframes_modal_warning")}
        </p>
        <button type="button" class="video-accept">Accept</button>
      </div>
    HTML
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
        "https://player.vimeo.com/video/#{match[2]}?dnt=1"
      elsif server == "YouTube"
        "https://www.youtube-nocookie.com/embed/#{match[2]}"
      end
    end

    def match
      @match ||= link.match(regex) if regex
    end
end
