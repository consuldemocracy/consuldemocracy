class Polls::AdvancedStatsComponent < ApplicationComponent
  attr_reader :stats
  delegate :number_to_stats_percentage, to: :helpers

  def initialize(stats)
    @stats = stats
  end

  def render?
    stats.advanced?
  end

  def number_with_percentage(number, percentage)
    safe_join([number, tag.small { tag.em("(#{number_to_stats_percentage(percentage)})") }], " ")
  end
end
