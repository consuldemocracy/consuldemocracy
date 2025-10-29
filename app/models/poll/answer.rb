class Poll::Answer < ApplicationRecord
  belongs_to :question, -> { with_hidden }, inverse_of: :answers
  belongs_to :option, class_name: "Poll::Question::Option"
  belongs_to :author, -> { with_hidden }, class_name: "User", inverse_of: :poll_answers

  delegate :poll, :poll_id, to: :question

  validates :question, presence: true
  validates :author, presence: true
  validates :answer, presence: true
  validates :option, uniqueness: { scope: :author_id }, allow_nil: true
  validates :answer, inclusion: { in: ->(poll_answer) { poll_answer.option.possible_answers }},
                     if: ->(poll_answer) { poll_answer.option.present? }

  scope :by_question, ->(question_id) { where(question_id: question_id) }
end
