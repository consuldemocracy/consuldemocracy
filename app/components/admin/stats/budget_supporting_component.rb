class Admin::Stats::BudgetSupportingComponent < ApplicationComponent
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end

  private

    def votes
      Vote.where(votable_type: "Budget::Investment")
          .includes(:budget_investment)
          .where(budget_investments: { heading_id: budget.heading_ids })
    end

    def vote_count
      votes.count
    end

    def user_count
      votes.select(:voter_id).distinct.count
    end

    def user_count_by_heading
      budget.headings.map do |heading|
        [heading, voters_in_heading(heading)]
      end
    end

    def voters_in_heading(heading)
      Vote.where(votable_type: "Budget::Investment")
          .includes(:budget_investment)
          .where(budget_investments: { heading_id: heading.id })
          .select("votes.voter_id").distinct.count
    end
end
