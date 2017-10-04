class Poll::QuestionAnswer < ActiveRecord::Base
  belongs_to :question, class_name: 'Poll::Question', foreign_key: 'poll_question_id'

  validates :title, presence: true
end
