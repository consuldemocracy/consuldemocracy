class Proposals::VotesComponent < ApplicationComponent
  attr_reader :proposal
  delegate :current_user, :link_to_verify_account, to: :helpers

  def initialize(proposal, vote_url: nil)
    @proposal = proposal
    @vote_url = vote_url
  end

  def vote_url
    @vote_url || vote_proposal_path(proposal, value: "yes")
  end

  private

    def voted?
      current_user&.voted_for?(proposal)
    end

    def can_vote?
      proposal.votable_by?(current_user)
    end

    def organization?
      current_user&.organization?
    end
end
