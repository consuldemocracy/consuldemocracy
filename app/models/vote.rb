class Vote < ActsAsVotable::Vote

  def self.already_voted_like_this?(voter:, votable:, value:)
    where(voter: voter, votable: votable, vote_flag: value).exists?
  end

  def self.vote_or_unvote_for(voter:, votable:, value:)
    if already_voted_like_this?(voter: voter, votable: votable, value: value)
      votable.unvote_by(voter)
    else
      votable.vote_by(voter: voter, vote: value)
    end
  end

end
