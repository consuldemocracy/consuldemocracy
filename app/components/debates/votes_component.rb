class Debates::VotesComponent < ApplicationComponent
  attr_reader :debate
  delegate :current_user, :link_to_verify_account, to: :helpers

  def initialize(debate)
    @debate = debate
  end

  private

    def can_vote?
      debate.votable_by?(current_user)
    end

    def organization?
      current_user&.organization?
    end
end
