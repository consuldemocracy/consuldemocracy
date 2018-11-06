class Budget
  class ValuatorGroupAssignment < ActiveRecord::Base
    belongs_to :valuator_group, counter_cache: :budget_investments_count
    belongs_to :investment, counter_cache: true
  end
end