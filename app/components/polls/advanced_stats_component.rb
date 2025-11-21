class Polls::AdvancedStatsComponent < ApplicationComponent
  attr_reader :stats
  use_helpers :number_to_stats_percentage

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
