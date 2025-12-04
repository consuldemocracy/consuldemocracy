class Widget::Feed < ApplicationRecord
  KINDS = %w[proposals debates processes upcoming].freeze

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

  def items
    send(kind)
  end

  def proposals
    Proposal.published.sort_by_hot_score.limit(limit)
  end

  def debates
    Debate.sort_by_hot_score.limit(limit)
  end

  def upcoming
    #    This returns a sorted mix of Budgets, Polls, Processes, and Events.
    limit_num = limit || 5

    # Fetch everything for the next 3 months
    items = Event.all_in_range(Date.current, 3.months.from_now)

    # Slice the top X items
    items.first(limit_num)
  end

  def processes
    Legislation::Process.open.published.order(created_at: :desc).limit(limit)
  end
end
