class Widget::Feed < ApplicationRecord
  KINDS = %w[proposals debates processes active_projects archived_projects].freeze

  def active?
    setting.value.present?
  end

  def setting
    Setting.find_by(key: "homepage.widgets.feeds.#{kind}")
  end

  def self.active
    KINDS.map do |kind|
      feed = find_or_create_by!(kind: kind)
      feed if feed.active?
    end.compact
  end

  def feature_enabled?
    case kind
    when 'active_projects', 'archived_projects'
      Setting.find_by(key: "feature.projects").value.present?
    else
      true
    end
  end

  def self.feature_enabled
    KINDS.map do |kind|
      feed = find_or_create_by!(kind: kind)
      feed if feed.feature_enabled?
    end.compact
  end

  def items
    send(kind)
  end

  def proposals
    Proposal.published.sort_by_hot_score.limit(limit)
  end

  def debates
    Debate.sort_by_hot_score.limit(limit)
  end

  def processes
    Legislation::Process.open.published.order("created_at DESC").limit(limit)
  end

  def active_projects
    Project.active.sort_by_created.limit(limit)
  end

  def archived_projects
    Project.archived.sort_by_created.limit(limit)
  end
end
