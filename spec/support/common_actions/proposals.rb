module Proposals
  # spec/features/proposal_ballots_spec.rb
  # spec/features/proposals_spec.rb
  def create_successful_proposals
    [create(:proposal, title: "Winter is coming", question: "Do you speak it?",
                       cached_votes_up: Proposal.votes_needed_for_success + 100),
     create(:proposal, title: "Fire and blood", question: "You talking to me?",
                       cached_votes_up: Proposal.votes_needed_for_success + 1)]
  end

  # spec/features/proposals_spec.rb
  def create_archived_proposals
    months_to_archive_proposals = Setting["months_to_archive_proposals"].to_i
    [
      create(:proposal, title: "This is an expired proposal",
                        created_at: months_to_archive_proposals.months.ago),
      create(:proposal, title: "This is an oldest expired proposal",
                        created_at: (months_to_archive_proposals + 2).months.ago)
    ]
  end

  # spec/features/official_positions_spec.rb
  # spec/features/proposals_spec.rb
  # spec/features/tags/budget_investments_spec.rb
  # spec/features/tags/proposals_spec.rb
  # spec/features/votes_spec.rb
  def create_featured_proposals
    [create(:proposal, :with_confidence_score, cached_votes_up: 100),
     create(:proposal, :with_confidence_score, cached_votes_up: 90),
     create(:proposal, :with_confidence_score, cached_votes_up: 80)]
  end
end
