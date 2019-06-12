class Budget
  class TrackerAssignment < ApplicationRecord
    belongs_to :tracker, counter_cache: :budget_investment_count
    belongs_to :investment, counter_cache: true
  end
end
