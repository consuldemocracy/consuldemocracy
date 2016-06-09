class Budget
  class Ballot < ActiveRecord::Base
    belongs_to :user
    belongs_to :budget
    belongs_to :heading

    has_many :lines, dependent: :destroy
    has_many :investments, through: :lines

    def total_amount_spent
      investments.sum(:price).to_i
    end

    def amount_spent(heading_id)
      investments.by_heading(heading_id).sum(:price).to_i
    end

    def amount_available(heading)
      budget.heading_price(heading) - amount_spent(heading.id)
    end
  end
end
