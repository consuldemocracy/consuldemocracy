module Abilities
  class Everyone
    include CanCan::Ability

    def initialize(user)
      can [:read, :map], Debate
      can [:read, :map, :summary], Proposal
      can :read, Comment
      can :read, Poll
      can :read, Poll::Question
      can [:read, :welcome], Budget
      can :read, Budget::Investment
      can :read, SpendingProposal
      can :read, Legislation
      can :read, User
      can [:search, :read], Annotation
      can [:read], Budget
      can [:read], Budget::Group
      can [:read, :print], Budget::Investment
      can :new, DirectMessage
    end
  end
end
