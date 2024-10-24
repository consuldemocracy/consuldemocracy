class SDG::Goals::TargetsComponent < ApplicationComponent
  attr_reader :goal

  def initialize(goal)
    @goal = goal
  end

  def render?
    feature?("sdg")
  end

  private

    def global_targets
      goal.targets
    end

    def local_targets
      goal.local_targets
    end

    def type(targets)
      if targets.model.name == "SDG::Target"
        "global"
      else
        "local"
      end
    end

    def active(targets)
      "is-active" if targets.model.name == "SDG::Target"
    end

    def title(targets)
      targets.model.model_name.human(count: :other).upcase_first
    end
end
