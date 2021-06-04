class Widget::Feeds::ParticipationComponent < ApplicationComponent
  attr_reader :feeds

  def initialize(feeds)
    @feeds = feeds
  end

  private

    def feed_debates?(feed)
      feed.kind == "debates"
    end

    def feed_proposals?(feed)
      feed.kind == "proposals"
    end

    def feed_budgets?(feed)
      feed.kind == "budgets"
    end
end
