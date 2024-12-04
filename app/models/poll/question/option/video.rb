class Poll::Question::Option::Video < ApplicationRecord
  belongs_to :option, class_name: "Poll::Question::Option", foreign_key: "answer_id", inverse_of: :videos
  include Videoable

  validates :title, presence: true
end
