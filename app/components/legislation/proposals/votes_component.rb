class Legislation::Proposals::VotesComponent < ApplicationComponent
  attr_reader :proposal
  delegate :current_user, :link_to_verify_account, :can?, to: :helpers

  def initialize(proposal)
    @proposal = proposal
  end

  private

    def can_vote?
      can?(:create, proposal.votes_for.new(voter: current_user))
    end

    def cannot_vote_text
      t("legislation.proposals.not_verified", verify_account: link_to_verify_account) unless can_vote?
    end
end
