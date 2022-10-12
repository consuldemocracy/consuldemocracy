class AUE::TagComponent < ApplicationComponent
  attr_reader :goal

  def initialize(goal)
    @goal = goal
  end

  def text
    if goal.is_a?(AUE::Goal)
      render AUE::Goals::IconComponent.new(goal)
    else
      goal.title
    end
  end
end
