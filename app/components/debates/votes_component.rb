class Debates::VotesComponent < ApplicationComponent
  attr_reader :debate, :debate_votes
  delegate :css_classes_for_vote, :current_user, :link_to_verify_account, :user_signed_in?, :votes_percentage, to: :helpers

  def initialize(debate, debate_votes:)
    @debate = debate
    @debate_votes = debate_votes
  end
end
