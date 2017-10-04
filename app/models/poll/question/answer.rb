class Poll::Question::Answer < ActiveRecord::Base
  belongs_to :question, class_name: 'Poll::Question', foreign_key: 'question_id'

  validates :title, presence: true

  def description
    super.try :html_safe
  end
end
