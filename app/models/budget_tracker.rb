class BudgetTracker < ApplicationRecord
  belongs_to :budget
  belongs_to :tracker
end
