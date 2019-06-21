module Proposals
  def create_successful_proposals
    [create(:proposal, title: "Winter is coming",
                       cached_votes_up: Proposal.votes_needed_for_success + 100),
     create(:proposal, title: "Fire and blood",
                       cached_votes_up: Proposal.votes_needed_for_success + 1)]
  end

  def create_archived_proposals
    months_to_archive_proposals = Setting["months_to_archive_proposals"].to_i
    [
      create(:proposal, title: "This is an expired proposal",
                        created_at: months_to_archive_proposals.months.ago),
      create(:proposal, title: "This is an oldest expired proposal",
                        created_at: (months_to_archive_proposals + 2).months.ago)
    ]
  end

  def create_featured_proposals
    [create(:proposal, :with_confidence_score, cached_votes_up: 200),
     create(:proposal, :with_confidence_score, cached_votes_up: 100),
     create(:proposal, :with_confidence_score, cached_votes_up: 90)]
  end
end
