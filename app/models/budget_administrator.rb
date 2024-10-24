class BudgetAdministrator < ApplicationRecord
  belongs_to :budget
  belongs_to :administrator
end
