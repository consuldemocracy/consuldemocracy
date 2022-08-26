class AUE::Goals::PlainTagListComponent < ApplicationComponent
  include AUE::TagList

  private

    def tags
      [*goal_tags, see_more_link].select(&:present?)
    end

    def goal_tags
      tag_records.map do |goal|
        render AUE::TagComponent.new(goal)
      end
    end

    def association_name
      :aue_goals
    end
end
