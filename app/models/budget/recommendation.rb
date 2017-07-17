class Budget
  class Recommendation < ActiveRecord::Base
    belongs_to :budget
    belongs_to :user, -> { with_hidden }
    belongs_to :investment

    validates :budget_id, presence: true
    validates :user_id, presence: true
    validates :investment_id, presence: true, uniqueness: {scope: [:user_id, :phase]}

    scope :by_budget, ->(b_id) { where(budget_id: b_id) }
    scope :by_phase, -> (ph) { where(phase: ph) }
  end
end