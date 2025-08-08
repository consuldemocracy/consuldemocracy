class Poll::Answer < ApplicationRecord
  belongs_to :question, -> { with_hidden }, inverse_of: :answers
  belongs_to :option, class_name: "Poll::Question::Option", optional: true
  belongs_to :author, -> { with_hidden }, class_name: "User", inverse_of: :poll_answers

  delegate :poll, :poll_id, to: :question

  validates :question, presence: true
  validates :author,   presence: true

  validates :answer, presence: true,
                     if: ->(a) { a.question&.unique? || a.question&.multiple? }

  validates :answer, inclusion: { in: ->(poll_answer) { poll_answer.option.possible_answers }},
                     if: ->(poll_answer) { poll_answer.option.present? }

  validates :text_answer, presence: true, if: ->(a) { a.question&.essay? }
  validates :option, uniqueness: { scope: :author_id }, allow_nil: true
  validate :max_votes

  scope :by_author, ->(author_id) { where(author_id: author_id) }
  scope :by_question, ->(question_id) { where(question_id: question_id) }

  private

    def max_votes
      return if question.blank? || !author || persisted? || question.max_votes.blank?

      if question.answers.by_author(author).count >= question.max_votes
        errors.add(:answer, "Maximum number of votes per user exceeded")
      end
    end
end
