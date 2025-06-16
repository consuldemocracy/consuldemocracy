class SDG::Goals::HelpPageComponent < ApplicationComponent
  attr_reader :goals

  def initialize(goals)
    @goals = goals
  end

  def render?
    feature?("sdg")
  end

  private

    def active_class(goal)
      "is-active" if goal.code == 1
    end
end
