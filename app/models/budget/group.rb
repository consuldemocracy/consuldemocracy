class Budget
  class Group < ActiveRecord::Base
    belongs_to :budget

    has_many :headings, dependent: :destroy

    validates :budget_id, presence: true
    validates :name, presence: true
  end
end