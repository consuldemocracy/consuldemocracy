class Vote < ActsAsVotable::Vote

  include Graphqlable

  def self.public_columns_for_api
    ["votable_id",
     "votable_type",
     "vote_flag",
     "created_at"]
  end

  def public_for_api?
    return false unless ["Proposal", "Debate", "Comment"].include? votable_type
    return false unless votable.present?
    return false if votable.hidden?
    return false if votable_type == "Comment" && (votable.commentable.blank? || votable.commentable.hidden?)
    return false unless votable.public_for_api?
    return true
  end

  scope :public_for_api, -> do
    where(%{(votes.votable_type = 'Debate' and votes.votable_id in (?)) or
            (votes.votable_type = 'Proposal' and votes.votable_id in (?)) or
            (votes.votable_type = 'Comment' and votes.votable_id in (?))},
          Debate.public_for_api.pluck(:id),
          Proposal.public_for_api.pluck(:id),
          Comment.public_for_api.pluck(:id))
  end

end
