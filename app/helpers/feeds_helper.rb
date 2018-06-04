module FeedsHelper

  def feed_debates?(feed)
    feed.kind == "debates"
  end

  def feed_proposals?(feed)
    feed.kind == "proposals"
  end

  def feed_processes?(feed)
    feed.kind == "processes"
  end

  def feed_processes_enabled?
    Setting['feature.homepage.widgets.feeds.processes'].present?
  end

end
