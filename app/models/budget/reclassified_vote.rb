class Budget
  class ReclassifiedVote < ActiveRecord::Base
    REASONS = %w(heading_changed unfeasible)

    belongs_to :user
    belongs_to :investment

    validates :user, presence: true
    validates :investment, presence: true
    validates :reason, inclusion: {in: REASONS, allow_nil: false}
  end
end