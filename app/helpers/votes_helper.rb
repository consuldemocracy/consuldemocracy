module VotesHelper
  # --- New Refactored Helper ---
  
  # Calculates the percentage of votes for a specific weight (e.g., 1, -1, or 0)
  # for any "votable" item (like a Debate).
  #
  # @param votable [ActiveRecord::Base] The item that was voted on (e.g., @debate)
  # @param weight [Integer] The specific weight to count (1, -1, or 0)
  # @return [String] A formatted percentage string (e.g., "33%")
  #
  def vote_percentage_for_weight(votable, weight)
    # 1. Get all votes for this item.
    #    We use `vote_scope: nil` to match the scope in our VoteButtonComponent.
    all_votes = votable.votes_for.where(vote_scope: nil)
    total_votes_count = all_votes.count

    # 2. Handle the "no votes" case to avoid dividing by zero.
    return "0%" if total_votes_count == 0

    # 3. Get the count for just the specific weight we're interested in.
    #    We can query the "all_votes" relation we already have.
    scoped_votes_count = all_votes.where(vote_weight: weight).count

    # 4. Calculate and format the percentage.
    #    We use `to_f` to ensure we get a decimal (float) for the division.
    percentage = (scoped_votes_count.to_f / total_votes_count * 100).round

    "#{percentage}%"
  end

  # --- Old Methods (Deprecated) ---
  #
  # The methods below are based on the old binary vote_flag system
  # and are no longer needed. They are replaced by `vote_percentage_for_weight`.
  #
  # def debate_percentage_of_likes(debate)
  #   (debate.likes.to_f * 100 / debate.total_votes).to_i
  # end
  #
  # def votes_percentage(vote, debate)
  #   return "0%" if debate.total_votes == 0
  #
  #   if vote == "likes"
  #     "#{debate_percentage_of_likes(debate)}%"
  #   elsif vote == "dislikes"
  #     "#{100 - debate_percentage_of_likes(debate)}%"
  #   end
  # end
end
