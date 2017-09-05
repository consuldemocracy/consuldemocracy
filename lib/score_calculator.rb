module ScoreCalculator

  EPOC           = Time.new(2015, 6, 15).in_time_zone
  COMMENT_WEIGHT = 1.0 / 5 # 1 positive vote / x comments
  TIME_UNIT      = 24.hours.to_f

  def self.hot_score(date, votes_total, votes_up, comments_count)
    total   = (votes_total + COMMENT_WEIGHT * comments_count).to_f
    ups     = (votes_up    + COMMENT_WEIGHT * comments_count).to_f
    downs   = total - ups
    score   = ups - downs
    offset  = Math.log([score.abs, 1].max, 10) * (ups / [total, 1].max)
    sign    = score <=> 0
    seconds = ((date || Time.current) - EPOC).to_f

    (((offset * sign) + (seconds / TIME_UNIT)) * 10000000).round
  end

  def self.confidence_score(votes_total, votes_up)
    return 1 unless votes_total > 0

    votes_total = votes_total.to_f
    votes_up    = votes_up.to_f
    votes_down  = votes_total - votes_up
    score       = votes_up - votes_down

    score * (votes_up / votes_total) * 100
  end

end
