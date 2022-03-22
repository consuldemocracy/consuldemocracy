class Poll::PartialResult < ApplicationRecord
  VALID_ORIGINS = %w[web booth].freeze

  belongs_to :question, -> { with_hidden }, inverse_of: :partial_results
  belongs_to :author, ->   { with_hidden }, class_name: "User", inverse_of: :poll_partial_results
  belongs_to :booth_assignment
  belongs_to :officer_assignment

  validates :question, presence: true
  validates :author, presence: true
  validates :answer, presence: true
  validates :answer, inclusion: { in: ->(a) { a.question.possible_answers }},
                     unless: ->(a) { a.question.blank? }
  validates :origin, inclusion: { in: ->(*) { VALID_ORIGINS }}

  scope :by_author, ->(author_id) { where(author_id: author_id) }
  scope :by_question, ->(question_id) { where(question_id: question_id) }

  before_save :update_logs

  def update_logs
    if will_save_change_to_amount? && amount_in_database.present?
      self.amount_log += ":#{amount_in_database}"
      self.officer_assignment_id_log += ":#{officer_assignment_id_in_database}"
      self.author_id_log += ":#{author_id_in_database}"
    end
  end
end
