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

# == Schema Information
#
# Table name: budget_reclassified_votes
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  investment_id :integer
#  reason        :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
