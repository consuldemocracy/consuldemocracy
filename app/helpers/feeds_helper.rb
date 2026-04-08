module FeedsHelper
  def feed_processes?(feed)
    feed.kind == "processes"
  end

  def feed_processes_enabled?
    Setting["homepage.widgets.feeds.processes"].present?
  end

  def feed_upcoming?(feed)
    # Return true ONLY if it is an upcoming feed AND the switch is on
    feed.kind == "upcoming"
  end

  def feed_upcoming_enabled?
    Setting["homepage.widgets.feeds.upcoming"].present?
  end
end
