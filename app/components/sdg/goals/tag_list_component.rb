class SDG::Goals::TagListComponent < ApplicationComponent
  include SDG::TagList

  private

    def record
      record_or_name if record_or_name.respond_to?(:sdg_goals)
    end

    def links
      [*goal_links, see_more_link(goals)]
    end

    def goal_links
      goals.order(:code).limit(limit).map do |goal|
        [
          render(SDG::Goals::IconComponent.new(goal)),
          index_by_goal(goal),
          title: filter_text(goal)
        ]
      end
    end

    def goals
      record&.sdg_goals || SDG::Goal.all
    end

    def index_by_goal(goal)
      index_by(goal: goal.code)
    end

    def i18n_namespace
      "goals"
    end
end
