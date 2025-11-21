class Polls::AdvancedStatsComponent < ApplicationComponent
  attr_reader :stats

  def initialize(stats)
    @stats = stats
  end

  def render?
    stats.advanced?
  end

  def number_with_percentage(number, percentage)
    safe_join([number, tag.small { tag.em("(#{percentage.round(2)}%)") }], " ")
  end
end
