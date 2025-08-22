class VotationType < ApplicationRecord
  belongs_to :questionable, polymorphic: true

  validate :cannot_be_open_ended_if_question_has_options

  QUESTIONABLE_TYPES = %w[Poll::Question].freeze

  enum :vote_type, { unique: 0, multiple: 1, open: 2 }

  validates :questionable, presence: true
  validates :questionable_type, inclusion: { in: ->(*) { QUESTIONABLE_TYPES }}
  validates :max_votes, presence: true, if: :max_votes_required?

  scope :accepts_options, -> { where.not(vote_type: "open") }

  def accepts_options?
    !open?
  end

  private

    def max_votes_required?
      multiple?
    end

    def cannot_be_open_ended_if_question_has_options
      if questionable&.question_options&.any? && !accepts_options?
        errors.add(:vote_type, :cannot_change_to_open_ended)
      end
    end
end
