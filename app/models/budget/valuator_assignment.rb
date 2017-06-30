class Budget
  class ValuatorAssignment < ApplicationRecord
    belongs_to :valuator, counter_cache: :budget_investments_count
    belongs_to :investment, counter_cache: true
  end
end
