class AUE::TagComponent < ApplicationComponent
  attr_reader :goal_or_target

  def initialize(goal_or_target)
    @goal_or_target = goal_or_target
  end

  def text
    if goal_or_target.is_a?(AUE::Goal)
      render AUE::Goals::IconComponent.new(goal_or_target)
    end
  end
end
