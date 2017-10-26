module Videable
  extend ActiveSupport::Concern

  VIMEO_REGEX = /vimeo.*(staffpicks\/|channels\/|videos\/|video\/|\/)([^#\&\?]*).*/
  YOUTUBE_REGEX = /youtu.*(be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/

  included do
    validate :valid_video_url?
  end

  def valid_video_url?
    return if video_url.blank?
    return if video_url.match(VIMEO_REGEX)
    return if video_url.match(YOUTUBE_REGEX)
    errors.add(:video_url, :invalid)
  end

end
