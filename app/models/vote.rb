class Vote < ActsAsVotable::Vote
  belongs_to :public_voter, -> { for_votes }, class_name: 'User', foreign_key: :voter_id

  scope :public_for_api, -> do
    joins("FULL OUTER JOIN debates ON votable_type = 'Debate' AND votable_id = debates.id").
    joins("FULL OUTER JOIN proposals ON votable_type = 'Proposal' AND votable_id = proposals.id").
    joins("FULL OUTER JOIN comments ON votable_type = 'Comment' AND votable_id = comments.id").
    where("votable_type = 'Proposal' AND proposals.hidden_at IS NULL OR votable_type = 'Debate' AND debates.hidden_at IS NULL OR votable_type = 'Comment' AND comments.hidden_at IS NULL")
  end
end
