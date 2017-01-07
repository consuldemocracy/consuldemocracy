module PublicVotersStats

  def votes_above_threshold?
    threshold = Setting["#{self.class.name.downcase}_api_votes_threshold"]
    threshold = (threshold ? threshold.to_i : default_threshold)
    (total_votes >= threshold)
  end

  def default_threshold
    200
  end
end
