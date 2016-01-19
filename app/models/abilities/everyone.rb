module Abilities
  class Everyone
    include CanCan::Ability

    def initialize(user)
      can :read, Debate
      can :read, Proposal
      can :read, Meeting
      can :read, Comment
      can :read, SpendingProposal
      can :read, Legislation
      can :read, User
      can [:search, :read], Annotation
    end
  end
end
