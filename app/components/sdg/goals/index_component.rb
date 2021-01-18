class SDG::Goals::IndexComponent < ApplicationComponent
  attr_reader :goals, :phases
  delegate :link_list, to: :helpers

  def initialize(goals, phases)
    @goals = goals
    @phases = phases
  end

  private

    def title
      t("sdg.goals.title")
    end

    def goal_links
      goals.map { |goal| goal_link(goal) }
    end

    def goal_link(goal)
      [icon(goal), sdg_goal_path(goal.code)]
    end

    def icon(goal)
      render SDG::Goals::IconComponent.new(goal)
    end
end
