module ProposalsHelper

  def progress_bar_percentage(proposal)
    case proposal.cached_votes_up
    when 0 then 0
    when 1..Proposal.votes_needed_for_success then (proposal.total_votes.to_f * 100 / Proposal.votes_needed_for_success).floor
    else 100
    end
  end

  def supports_percentage(proposal)
    percentage = (proposal.total_votes.to_f * 100 / Proposal.votes_needed_for_success)
    case percentage
    when 0 then "0%"
    when 0..(0.1) then "0.1%"
    when (0.1)..100 then number_to_percentage(percentage, strip_insignificant_zeros: true, precision: 1)
    else "100%"
    end
  end

  def namespaced_proposal_path(proposal, options={})
    @namespace_proposal_path ||= namespace
    case @namespace_proposal_path
    when "management"
      management_proposal_path(proposal, options)
    else
      proposal_path(proposal, options)
    end
  end

  def retire_proposals_options
    Proposal::RETIRE_OPTIONS.collect { |option| [ t("proposals.retire_options.#{option}"), option ] }
  end

  #TODO: Filtrar por las propuestas ganadoras
  def valid_proposals
    Proposal.all
  end

  #TODO: Tomar el desafío activo (debe ser solo uno)
  def challenge
    Problem.last
  end

  def most_voted_proposals
    Proposal.all.reorder(cached_votes_up: :desc).first(3)
  end

  def winning_proposal?(proposal)
    most_voted_proposals.select{ |p| p.id == proposal.id}.any?
  end

  def problem_geozones(challenge)
    array = []
    challenge.geozones.each do |g|
      array.push(g.id)
    end
    return array
  end
end
