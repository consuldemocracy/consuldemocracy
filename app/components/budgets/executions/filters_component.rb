class Budgets::Executions::FiltersComponent < ApplicationComponent
  attr_reader :budget, :statuses

  def initialize(budget, statuses)
    @budget = budget
    @statuses = statuses
  end

  def options_for_milestone_tags
    budget.investments_milestone_tags.map do |tag|
      ["#{tag} (#{budget.investments.winners.by_tag(tag).count})", tag]
    end
  end

  private

    def filters_select_counts(status)
      budget.investments.winners.with_milestone_status_id(status).count
    end
end
