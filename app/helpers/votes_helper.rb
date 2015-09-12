module VotesHelper

  def css_classes_for_debate_vote(debate_votes, debate)
    case debate_votes[debate.id]
    when true
      {in_favor: "voted", against: "no-voted"}
    when false
      {in_favor: "no-voted", against: "voted"}
    else
      {in_favor: "", against: ""}
    end
  end

  def css_classes_for_proposal_vote(proposal_votes, proposal)
    case proposal_votes[proposal.id]
    when true
      {in_favor: "voted"}
    else
      {in_favor: ""}
    end
  end

end
