class AUE::LocalGoals::TagListComponent < ApplicationComponent
  include AUE::TagList

  def render?
    feature?("aue")
  end

  private
    def tags
      [*local_goal_tags].select(&:present?)
    end

    def local_goal_tags
      tag_records.map do |goal|
        render AUE::TagComponent.new(goal)
      end
    end

    def association_name
      :aue_local_goals
    end

end
