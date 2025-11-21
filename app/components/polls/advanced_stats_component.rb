class Polls::AdvancedStatsComponent < ApplicationComponent
  attr_reader :stats

  def initialize(stats)
    @stats = stats
  end

  def render?
    stats.advanced?
  end
end
