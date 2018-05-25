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

end
