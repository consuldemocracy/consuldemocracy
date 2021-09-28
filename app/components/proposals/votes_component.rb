class Proposals::VotesComponent < ApplicationComponent
  attr_reader :proposal, :vote_url, :proposal_votes
  delegate :current_user, :link_to_verify_account, :user_signed_in?, :voted_for?, to: :helpers

  def initialize(proposal, vote_url:, proposal_votes:)
    @proposal = proposal
    @vote_url = vote_url
    @proposal_votes = proposal_votes
  end
end
