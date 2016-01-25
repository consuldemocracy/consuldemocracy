module Abilities
  class Everyone
    include CanCan::Ability

    def initialize(user)
      can [:read, :map], Debate
      can [:read, :map], Proposal
      can :read, Comment
      can :read, SpendingProposal
      can :read, Legislation
      can :read, User
      can [:search, :read], Annotation
    end
  end
end
