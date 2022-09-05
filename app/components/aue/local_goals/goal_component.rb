class AUE::LocalGoals::GoalComponent < ApplicationComponent
  attr_reader :local_goal
  delegate :code, to: :local_goal

  def initialize(local_goal)
    @local_goal = local_goal
  end
end
