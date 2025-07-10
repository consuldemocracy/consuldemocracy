module ScoreCalculator
  def self.hot_score(resource)
    return 0 unless resource.created_at

    period = [1, [max_period, resource_age(resource)].min].max

    votes_total = resource.votes_for.where("created_at >= ?", period.days.ago).count
    votes_up    = resource.get_upvotes.where("created_at >= ?", period.days.ago).count
    votes_down  = votes_total - votes_up
    votes_score = votes_up - votes_down

    (votes_score.to_f / period).round
  end

  def self.confidence_score(votes_total, votes_up)
    return 1 unless votes_total > 0

    votes_total = votes_total.to_f
    votes_up    = votes_up.to_f
    votes_down  = votes_total - votes_up
    score       = votes_up - votes_down

    score * (votes_up / votes_total) * 100
  end

  def self.max_period
    Setting["hot_score_period_in_days"].to_i
  end

  def self.resource_age(resource)
    ((Time.current - resource.created_at) / 1.day).ceil
  end
end
