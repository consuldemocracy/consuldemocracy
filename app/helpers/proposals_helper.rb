module ProposalsHelper

  def progress_bar_percentage(proposal)
    case proposal.cached_votes_up
      when 0 then 0
      when 1..Proposal.votes_needed_for_success then (proposal.cached_votes_up.to_f * 100 / Proposal.votes_needed_for_success).floor
      else 100
    end
  end

end