module Videoable
  extend ActiveSupport::Concern

  included do
    validate :valid_video_url?
  end

  VIMEO_REGEX = /vimeo.*(staffpicks\/|channels\/|videos\/|video\/|\/)([^#\&\?]*).*/
  YOUTUBE_REGEX = /youtu.*(be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/

  def valid_video_url?
    url = send(video_url_field)

    return if url.blank?
    return if url.match(VIMEO_REGEX)
    return if url.match(YOUTUBE_REGEX)

    errors.add(video_url_field, :invalid)
  end

  def video_url_field
    if has_attribute?(:video_url)
      :video_url
    else
      :url
    end
  end
end
