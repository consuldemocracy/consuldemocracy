class Budgets::Stats::AdvancedStatsComponent < ApplicationComponent
  attr_reader :stats
  delegate :number_with_info_tags, :number_to_stats_percentage, to: :helpers

  def initialize(stats)
    @stats = stats
  end

  def render?
    stats.advanced?
  end

  private

    def headings
      stats.budget.headings.sort_by_name
    end
end
