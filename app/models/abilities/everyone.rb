module Abilities
  class Everyone
    include CanCan::Ability

    def initialize(user)
      can [:read, :map], Debate
      can [:read, :map, :summary], Proposal
      can :read, Comment
      can [:read, :welcome, :select_district, :stats, :results], SpendingProposal
      can :read, Legislation
      can :read, User
      can [:search, :read], Annotation
      can :new, DirectMessage
    end
  end
end
