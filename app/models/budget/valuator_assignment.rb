class Budget
  class ValuatorAssignment < ApplicationRecord
    belongs_to :valuator, counter_cache: :budget_investments_count
    belongs_to :investment, counter_cache: true
  end
end

# == Schema Information
#
# Table name: budget_valuator_assignments
#
#  id            :integer          not null, primary key
#  valuator_id   :integer
#  investment_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
