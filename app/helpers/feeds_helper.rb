module FeedsHelper
  def feed_processes?(feed)
    feed.kind == "processes"
  end

  def feed_processes_enabled?
    Setting["homepage.widgets.feeds.processes"].present?
  end
end
