class Legislation::Proposals::VotesComponent < ApplicationComponent
  attr_reader :proposal
  delegate :css_classes_for_vote, :current_user, :link_to_verify_account, :user_signed_in?, :votes_percentage, to: :helpers

  def initialize(proposal)
    @proposal = proposal
  end
end
