module Abilities
  class Moderator
    include CanCan::Ability

    def initialize(user)
      self.merge Abilities::Moderation.new(user)

      can :comment_as_moderator, [Debate, Comment, Proposal, SpendingProposal, Poll::Question, ProbeOption, Budget::Investment]
    end
  end
end
