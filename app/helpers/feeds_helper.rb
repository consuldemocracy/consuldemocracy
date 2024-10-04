module FeedsHelper
  def feed_processes?(feed)
    feed.kind == "processes"
  end
  def feed_active_projects?(feed)
    feed.kind == "active_projects"
  end
  def feed_archived_projects?(feed)
    feed.kind == "archived_projects"
  end

  def feed_processes_enabled?
    Setting["homepage.widgets.feeds.processes"].present?
  end
end
