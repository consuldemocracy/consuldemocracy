class Widget::Feed < ActiveRecord::Base
  self.table_name = "widget_feeds"

  KINDS = %w(proposals debates processes)

  def active?(kind)
    Setting["feature.homepage.widgets.feeds.#{kind}"].present?
  end

  def self.active
    KINDS.collect do |kind|
      feed = new(kind: kind)
      feed if feed.active?(kind)
    end.compact
  end

  def items
    send(kind)
  end

  def proposals
    Proposal.sort_by_hot_score.limit(limit)
  end

  def debates
    Debate.sort_by_hot_score.limit(limit)
  end

  def processes
    Legislation::Process.open.limit(limit)
  end

  def limit
    3
  end

end