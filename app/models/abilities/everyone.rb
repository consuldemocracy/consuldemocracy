module Abilities
  class Everyone
    include CanCan::Ability

    def initialize(user)
      can [:read, :map], Debate
      can [:read, :map, :summary], Proposal
      can :read, Comment
      can :read, SpendingProposal
      can :welcome, SpendingProposal
      can :read, Legislation
      can :read, User
      can [:search, :read], Annotation
      can :new, SurveyAnswer
    end
  end
end
