class Vote < ActsAsVotable::Vote

  include Graphqlable
  
  def self.public_for_api
    joins("FULL OUTER JOIN debates ON votable_type = 'Debate' AND votable_id = debates.id").
    joins("FULL OUTER JOIN proposals ON votable_type = 'Proposal' AND votable_id = proposals.id").
    joins("FULL OUTER JOIN comments ON votable_type = 'Comment' AND votable_id = comments.id").
    where("votable_type = 'Proposal' AND proposals.hidden_at IS NULL OR votable_type = 'Debate' AND debates.hidden_at IS NULL OR votable_type = 'Comment' AND comments.hidden_at IS NULL")
  end

  def public_timestamp
    self.created_at.change(min: 0)
  end
end
