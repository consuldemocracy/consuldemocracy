class SDG::Goals::ShowComponent < ApplicationComponent
  attr_reader :goal
  delegate :code, to: :goal

  def initialize(goal)
    @goal = goal
  end

  def feeds
    SDG::Widget::Feed.for_goal(goal)
  end

  private

    def processes_feed
      feeds.find { |feed| feed.kind == "processes" }
    end

    def heading
      safe_join([tag.span(code, class: "goal-code"), tag.span(split_title, class: "goal-title")], " ")
    end

    def long_description
      sanitize t("sdg.goals.goal_#{code}.long_description")
    end

    def split_title
      safe_join(goal.title_in_two_lines.split("\n").map { |text| tag.span(text) }, " ")
    end
end
