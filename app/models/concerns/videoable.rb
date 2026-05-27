module Videoable
  extend ActiveSupport::Concern

  included do
    validate :valid_video_url
  end

  VIMEO_REGEX = /vimeo.*(staffpicks\/|channels\/|videos\/|video\/|\/)([^#\&\?]*).*/
  YOUTUBE_REGEX = /youtu.*(be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/

  def valid_video_url
    errors.add(video_url_field, :invalid) unless valid_video_url?
  end

  def valid_video_url?
    url = send(video_url_field)

    url.blank? || VIMEO_REGEX.match?(url) || YOUTUBE_REGEX.match?(url)
  end

  def video_url_field
    if has_attribute?(:video_url)
      :video_url
    else
      :url
    end
  end
end
