module VotesHelper

  def css_classes_for_debate_vote(voted_values, debate)
    case voted_values[debate.id]
    when true
      {in_favor: "voted", against: "no-voted"}
    when false
      {in_favor: "no-voted", against: "voted"}
    else
      {in_favor: "", against: ""}
    end
  end

end