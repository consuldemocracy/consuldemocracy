class Budget
  class ValuatorGroupAssignment < ActiveRecord::Base
    belongs_to :valuator_group
    belongs_to :investment
  end
end