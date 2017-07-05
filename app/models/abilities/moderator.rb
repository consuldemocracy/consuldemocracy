module Abilities
  class Moderator
    include CanCan::Ability

    def initialize(user)
      merge Abilities::Moderation.new(user)

      can :comment_as_moderator, [Debate, Comment, Proposal, SpendingProposal, ProbeOption, Poll::Question, Budget::Investment, Legislation::Question, Legislation::Annotation]
    end
  end
end
