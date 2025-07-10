module Abilities
  class Moderator
    include CanCan::Ability

    def initialize(user)
      merge Abilities::Moderation.new(user)

      can :comment_as_moderator, [Debate, Comment, Proposal, Budget::Investment, Poll::Question,
                                  Legislation::Question, Legislation::Annotation, Legislation::Proposal, Topic]
    end
  end
end
