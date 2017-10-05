class Poll::Question::Answer < ActiveRecord::Base
	include Galleryable

  belongs_to :question, class_name: 'Poll::Question', foreign_key: 'question_id'
  has_many :videos, class_name: 'Poll::Question::Answer::Video'

  validates :title, presence: true

  def description
    super.try :html_safe
  end
end
