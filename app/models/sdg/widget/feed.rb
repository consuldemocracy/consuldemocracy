class SDG::Widget::Feed
  attr_reader :feed, :goal
  delegate :kind, to: :feed

  def initialize(feed, goal)
    @feed = feed
    @goal = goal
  end

  def items
    feed.items.by_goal(goal.code)
  end

  def self.for_goal(goal)
    ::Widget::Feed.active.map { |feed| new(feed, goal) }
  end
end
