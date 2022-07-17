module VotesHelper
  def debate_percentage_of_likes(debate)
    debate.likes.percent_of(debate.total_votes)
  end

  def votes_percentage(vote, debate)
    return "0%" if debate.total_votes == 0

    if vote == "likes"
      "#{debate_percentage_of_likes(debate)}%"
    elsif vote == "dislikes"
      "#{100 - debate_percentage_of_likes(debate)}%"
    end
  end
end
