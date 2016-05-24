class Budget
  class Ballot < ActiveRecord::Base
    belongs_to :user
    belongs_to :budget

    has_many :lines, dependent: :destroy
    has_many :investments, through: :lines

    def total_amount_spent
      investments.sum(:price).to_i
    end

    def amount_spent(heading)
      investments.by_heading(heading).sum(:price).to_i
    end
  end
end
