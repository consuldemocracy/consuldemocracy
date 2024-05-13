class Poll::Question::Option::Video < ApplicationRecord
  belongs_to :option, class_name: "Poll::Question::Option", foreign_key: "answer_id", inverse_of: :videos

  VIMEO_REGEX = /vimeo.*(staffpicks\/|channels\/|videos\/|video\/|\/)([^#\&\?]*).*/
  YOUTUBE_REGEX = /youtu.*(be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/

  validates :title, presence: true
  validate :valid_url?

  def valid_url?
    return if url.blank?
    return if url.match(VIMEO_REGEX)
    return if url.match(YOUTUBE_REGEX)

    errors.add(:url, :invalid)
  end
end
