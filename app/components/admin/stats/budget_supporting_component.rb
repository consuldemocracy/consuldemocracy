class Admin::Stats::BudgetSupportingComponent < ApplicationComponent
  attr_reader :budget
  use_helpers :include_stat_graphs_javascript

  def initialize(budget)
    @budget = budget
  end

  private

    def stats
      @stats ||= Budget::Stats.new(budget, cache: false)
    end

    def headings_stats
      @headings_stats ||= stats.headings
    end

    def vote_count
      stats.total_supports
    end

    def user_count
      stats.total_participants_support_phase
    end

    def user_count_by_heading
      budget.headings.map do |heading|
        [heading, headings_stats[heading.id][:total_participants_support_phase]]
      end
    end

    def chart
      @chart ||= Ahoy::Chart.new("budget_investment_supported")
    end
end
