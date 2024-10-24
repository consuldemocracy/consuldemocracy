class Debates::VotesComponent < ApplicationComponent
  attr_reader :debate
  use_helpers :current_user, :link_to_verify_account

  def initialize(debate)
    @debate = debate
  end

  private

    def can_vote?
      debate.votable_by?(current_user)
    end

    def cannot_vote_text
      t("votes.anonymous", verify_account: link_to_verify_account) unless can_vote?
    end
end
