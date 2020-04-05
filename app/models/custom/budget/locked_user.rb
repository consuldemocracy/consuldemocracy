class Budget
  class LockedUser < ActiveRecord::Base
    belongs_to :budget

    validates :budget, presence: true, uniqueness: { scope: :document_number }
    validates :document_type, presence: true
    validates :document_number, presence: true
  end
end
