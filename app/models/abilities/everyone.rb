module Abilities
  class Everyone
    include CanCan::Ability

    def initialize(user)
      can [:read, :map], Debate
      can [:read, :map, :summary], Proposal
      can :read, Comment
      can :read, SpendingProposal
      can :read, LegacyLegislation
      can :read, User
      can [:search, :read], Annotation
      can :new, DirectMessage
      can [:read], Legislation::Process
      can [:read], Legislation::DraftVersion
    end
  end
end
