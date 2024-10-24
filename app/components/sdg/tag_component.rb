class SDG::TagComponent < ApplicationComponent
  attr_reader :goal_or_target

  def initialize(goal_or_target)
    @goal_or_target = goal_or_target
  end

  def text
    if goal_or_target.is_a?(SDG::Goal)
      render SDG::Goals::IconComponent.new(goal_or_target)
    else
      "#{SDG::Target.model_name.human} #{goal_or_target.code}"
    end
  end
end
