class Shared::EmbeddedVideoComponent < ApplicationComponent
  attr_reader :record

  def initialize(record)
    @record = record
  end

  def render?
    embed_url.present?
  end

  def embedded_video_code
    "<iframe #{iframe_attributes}></iframe>"
  end

  private

    def title
      t("proposals.show.embed_video_title", proposal: record.title)
    end

    def embed_url
      record.embed_video_url
    end

    def iframe_attributes
      tag.attributes(src: embed_url, style: "border:0;", allowfullscreen: true, title: title)
    end
end
