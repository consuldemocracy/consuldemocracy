class VotationType < ApplicationRecord
  belongs_to :questionable, polymorphic: true

  delegate :t, to: "ApplicationController.helpers"

  validate :cannot_be_essay_if_question_has_options

  QUESTIONABLE_TYPES = %w[Poll::Question].freeze

  enum :vote_type, { unique: 0, multiple: 1, essay: 3 }

  validates :questionable, presence: true
  validates :questionable_type, inclusion: { in: ->(*) { QUESTIONABLE_TYPES }}
  validates :max_votes, presence: true, if: :max_votes_required?

  private

    def max_votes_required?
      multiple?
    end

    def cannot_be_essay_if_question_has_options
      if essay? && questionable&.question_options&.exists?
        errors.add(:vote_type, I18n.t("poll_questions.form.change_votation_type"))
      end
    end
end
