class Legislation::Proposals::VotesComponent < ApplicationComponent
  attr_reader :proposal, :legislation_proposal_votes
  delegate :css_classes_for_vote, :current_user, :link_to_verify_account, :user_signed_in?, :voted_for?, :votes_percentage, to: :helpers

  def initialize(proposal, legislation_proposal_votes:)
    @proposal = proposal
    @legislation_proposal_votes = legislation_proposal_votes
  end
end
