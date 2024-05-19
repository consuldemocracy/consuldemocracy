class Poll::Question::Answer::Video < ApplicationRecord
  belongs_to :answer, class_name: "Poll::Question::Answer"
  include Videoable

  validates :title, presence: true
end
