module Videoable
  extend ActiveSupport::Concern

  included do
    validate :valid_video_url
  end

  def valid_video_url
    errors.add(video_url_field, :invalid) unless valid_video_url?
  end

  def valid_video_url?
    video_url_value.blank? || video_url_parser.valid?
  end

  def embed_video_url
    video_url_parser.embed_url
  end

  def video_url_field
    if has_attribute?(:video_url)
      :video_url
    else
      :url
    end
  end

  def video_url_value
    send(video_url_field)
  end

  def video_url_parser
    VideoUrlParser.new(video_url_value)
  end
end
