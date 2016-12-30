class Vote < ActsAsVotable::Vote

  def self.public_columns
    ["votable_id",
     "votable_type",
     "vote_flag",
     "created_at"]
  end

  def public?
    return false unless ["Proposal", "Debate", "Comment"].include? votable_type
    return false if votable.try(:hidden?)
    return true
  end

end