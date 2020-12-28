class SDG::Goals::ShowComponent < ApplicationComponent
  attr_reader :goal
  delegate :back_link_to, to: :helpers

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
end
