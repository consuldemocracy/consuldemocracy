class SDG::Goals::ShowComponent < ApplicationComponent
  attr_reader :goal

  def initialize(goal)
    @goal = goal
  end
end
