class VotationType < ApplicationRecord
  belongs_to :questionable, polymorphic: true

  QUESTIONABLE_TYPES = %w[Poll::Question].freeze

  enum :vote_type, { unique: 0, multiple: 1, essay: 3 }

  validates :questionable, presence: true
  validates :questionable_type, inclusion: { in: ->(*) { QUESTIONABLE_TYPES }}
  validates :max_votes, presence: true, if: :max_votes_required?

  after_create :votation_type_essay_auto_option, if: -> { essay? }

  private

    def max_votes_required?
      multiple?
    end

    def votation_type_essay_auto_option
      questionable.question_options.create!(title: "open text", open_text: true)
    end
end
