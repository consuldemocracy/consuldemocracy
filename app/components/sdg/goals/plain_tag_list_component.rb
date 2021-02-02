class SDG::Goals::PlainTagListComponent < ApplicationComponent
  include SDG::TagList

  private

    def record
      record_or_name
    end

    def tags
      [*goal_tags, see_more_link(:sdg_goals)].select(&:present?)
    end

    def goal_tags
      goals.order(:code).limit(limit).map do |goal|
        render SDG::Goals::IconComponent.new(goal)
      end
    end

    def goals
      record.sdg_goals
    end

    def i18n_namespace
      "goals"
    end
end
