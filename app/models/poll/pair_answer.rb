class Poll::PairAnswer < ApplicationRecord

  belongs_to :question, -> { with_hidden }
  belongs_to :author, ->   { with_hidden }, class_name: "User", foreign_key: "author_id"
  belongs_to :answer_right, class_name: "Poll::Question::Answer", foreign_key: "answer_rigth_id"
  belongs_to :answer_left, class_name: "Poll::Question::Answer", foreign_key: "answer_left_id"

  delegate :poll, :poll_id, to: :question

  validates :question, presence: true
  validates :author, presence: true
  validates :answer_left, presence: true
  validates :answer_right, presence: true

  validates :answer_left, inclusion: { in: ->(a) { a.question.question_answers.visibles }},
            unless: ->(a) { a.question.blank? }

  validates :answer_right, inclusion: { in: ->(a) { a.question.question_answers.visibles }},
            unless: ->(a) { a.question.blank? }


  scope :by_author, ->(author_id) { where(author_id: author_id) }
  scope :by_question, ->(question_id) { where(question_id: question_id) }

  def self.generate_pair(question, user)
    answers = question.question_answers.visibles.sample(2)
    question.pair_answers.by_author(user).map(&:destroy)
    question.pair_answers.create(author: user, answer_left: answers[0], answer_right: answers[1])
  end

  def answers
    [answer_left, answer_right].compact
  end
end
