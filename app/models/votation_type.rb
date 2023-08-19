class VotationType < ApplicationRecord
  belongs_to :questionable, polymorphic: true

  QUESTIONABLE_TYPES = %w[Poll::Question].freeze

  enum vote_type: %w[unique multiple]

  validates :questionable, presence: true
  validates :questionable_type, inclusion: { in: ->(*) { QUESTIONABLE_TYPES }}
  validates :max_votes, presence: true, if: :max_votes_required?

  private

    def max_votes_required?
      multiple?
    end
end
