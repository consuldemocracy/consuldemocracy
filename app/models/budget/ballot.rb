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
      budget.heading_price(heading) - amount_spent(heading.try(:id))
    end

    def has_lines_with_no_heading?
      investments.no_heading.count > 0
    end

    def has_lines_with_heading?
      self.heading_id.present?
    end

    def has_investment?(investment)
      self.investment_ids.include?(investment.id)
    end
  end
end
