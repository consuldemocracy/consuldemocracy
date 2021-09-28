class Debates::VotesComponent < ApplicationComponent
  attr_reader :debate
  delegate :css_classes_for_vote, :current_user, :link_to_verify_account, :user_signed_in?, :votes_percentage, to: :helpers

  def initialize(debate)
    @debate = debate
  end
end
