class AUE::Goals::ShowComponent < ApplicationComponent
  attr_reader :goal
  delegate :code, to: :goal

  def initialize(goal)
    @goal = goal
  end

  def feeds
    AUE::Widget::Feed.for_goal(goal)
  end

  private

    def processes_feed
      feeds.find { |feed| feed.kind == "processes" }
    end

    def heading
      safe_join([tag.span(split_title, class: "goal-title"), tag.span(description, class: "goal-description")], " ")
    end

    def long_description
      sanitize t("aue.goals.goal_#{code}.description")
    end

    def split_title
      goal.title + ':'
    end

    def description
      goal.description
    end
end
