module VotesHelper

  def votes_percentage(vote, debate)
    return "0%" if debate.total_votes == 0
    if vote == 'likes'
      debate.likes.percent_of(debate.total_votes).to_s + "%"
    elsif vote == 'dislikes'
      (100 - debate.likes.percent_of(debate.total_votes)).to_s + "%"
    end
  end

  def css_classes_for_vote(votes, votable)
    case votes[votable.id]
    when true
      {in_favor: "voted", against: "no-voted"}
    when false
      {in_favor: "no-voted", against: "voted"}
    else
      {in_favor: "", against: ""}
    end
  end

  def voted_for?(votes, votable)
    votes[votable.id]
  end

end
