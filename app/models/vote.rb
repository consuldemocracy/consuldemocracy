class Vote < ActsAsVotable::Vote

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
    return false if votable_type == "Comment" && votable.commentable.hidden?
    return false unless votable.public_for_api?
    return true
  end

end