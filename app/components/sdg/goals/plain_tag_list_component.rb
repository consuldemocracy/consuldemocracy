class SDG::Goals::PlainTagListComponent < ApplicationComponent
  include SDG::TagList

  private

    def tags
      [*goal_tags, see_more_link].select(&:present?)
    end

    def goal_tags
      tag_records.map do |goal|
        render SDG::TagComponent.new(goal)
      end
    end

    def association_name
      :sdg_goals
    end
end
