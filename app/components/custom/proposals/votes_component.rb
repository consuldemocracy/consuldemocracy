class Proposals::VotesComponent < ApplicationComponent
  attr_reader :proposal
  delegate :current_user, :link_to_verify_account, to: :helpers

  def initialize(proposal, vote_url: nil)
    @proposal = proposal
    @vote_url = vote_url
  end


  def vote_url
    vote_proposal_path(proposal, value: "yes")
  end

  def un_vote_url
    un_vote_proposal_path(proposal, value: "no")
  end

  private

  def voted?
    # current_user&.voted_for?(proposal)

    proposal.voted_yes_by_current_user(current_user)
  end

  def can_vote?
    proposal.votable_by?(current_user)
  end

  def support_aria_label
    t("proposals.proposal.support_label", proposal: proposal.title)
  end

  def cannot_vote_text
    t("votes.verified_only", verify_account: link_to_verify_account) unless can_vote?
  end
end
