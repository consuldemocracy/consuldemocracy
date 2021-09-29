class Legislation::Proposals::VotesComponent < ApplicationComponent
  attr_reader :proposal
  delegate :css_classes_for_vote, :current_user, :link_to_verify_account, :votes_percentage, to: :helpers

  def initialize(proposal)
    @proposal = proposal
  end

  private

    def voted_classes
      @voted_classes ||= css_classes_for_vote(proposal)
    end

    def can_vote?
      proposal.votable_by?(current_user)
    end

    def organization?
      current_user&.organization?
    end
end
