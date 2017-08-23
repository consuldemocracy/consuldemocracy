class Budget
  class Ballot < ActiveRecord::Base
    belongs_to :user
    belongs_to :budget

    has_many :lines, dependent: :destroy
    has_many :investments, through: :lines
    has_many :groups, -> { uniq }, through: :lines
    has_many :headings, -> { uniq }, through: :groups

    def add_investment(investment)
      lines.create(investment: investment).persisted?
    end

    def total_amount_spent
      investments.sum(:price).to_i
    end

    def amount_spent(heading)
      investments.by_heading(heading.id).sum(:price).to_i
    end

    def formatted_amount_spent(heading)
      budget.formatted_amount(amount_spent(heading))
    end

    def amount_available(heading)
      budget.heading_price(heading) - amount_spent(heading)
    end

    def formatted_amount_available(heading)
      budget.formatted_amount(amount_available(heading))
    end

    def has_lines_in_group?(group)
      groups.include?(group)
    end

    def wrong_budget?(heading)
      heading.budget_id != budget_id
    end

    def different_heading_assigned?(heading)
      other_heading_ids = heading.group.heading_ids - [heading.id]
      lines.where(heading_id: other_heading_ids).exists?
    end

    def valid_heading?(heading)
      !wrong_budget?(heading) && !different_heading_assigned?(heading)
    end

    def has_lines_with_no_heading?
      investments.no_heading.count > 0
    end

    def has_lines_with_heading?
      heading_id.present?
    end

    def has_lines_in_heading?(heading)
      investments.by_heading(heading.id).any?
    end

    def has_investment?(investment)
      investment_ids.include?(investment.id)
    end

    def heading_for_group(group)
      return nil unless has_lines_in_group?(group)
      investments.where(group: group).first.heading
    end

  end
end
