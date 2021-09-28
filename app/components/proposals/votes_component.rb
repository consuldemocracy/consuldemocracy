class Proposals::VotesComponent < ApplicationComponent
  attr_reader :proposal, :vote_url
  delegate :current_user, :link_to_verify_account, :user_signed_in?, to: :helpers

  def initialize(proposal, vote_url:)
    @proposal = proposal
    @vote_url = vote_url
  end
end
