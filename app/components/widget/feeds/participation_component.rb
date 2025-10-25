class Widget::Feeds::ParticipationComponent < ApplicationComponent
  attr_reader :feeds, :current_user

  def initialize(feeds, current_user = nil)
    @feeds = feeds
    @current_user = current_user
  end

  private

    def feed_debates?(feed)
      feed.kind == "debates"
    end

    def feed_proposals?(feed)
      feed.kind == "proposals"
    end
end
