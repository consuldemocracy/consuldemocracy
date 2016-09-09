class Budget
  class Ballot < ActiveRecord::Base
    belongs_to :user
    belongs_to :budget

    has_many :lines, dependent: :destroy
    has_many :investments, through: :lines
    has_many :groups, -> { uniq }, through: :lines
    has_many :headings, -> { uniq }, through: :groups

    def add_investment(investment)
      lines.create!(budget: budget, investment: investment, heading: investment.heading, group_id: investment.heading.group_id)
    end

    def total_amount_spent
      investments.sum(:price).to_i
    end

    def amount_spent(heading_id)
      investments.by_heading(heading_id).sum(:price).to_i
    end

    def amount_available(heading)
      budget.heading_price(heading) - amount_spent(heading.id)
    end

    def has_lines_in_group?(group)
      self.groups.include?(group)
    end

    def valid_heading?(heading)
      group = heading.group
      return false if group.budget_id != budget_id

      line = lines.where(heading_id: group.heading_ids).first
      return false if line.present? && line.heading_id != heading.id

      true
    end

    def has_lines_with_no_heading?
      investments.no_heading.count > 0
    end

    def has_lines_with_heading?
      self.heading_id.present?
    end

    def has_lines_in_heading?(heading)
      investments.by_heading(heading.id).any?
    end

    def has_investment?(investment)
      self.investment_ids.include?(investment.id)
    end

    def heading_for_group(group)
      self.headings.where(group: group).first.id
    end

  end
end
