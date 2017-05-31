module Abilities
  class Everyone
    include CanCan::Ability

    def initialize(user)
      can [:read, :map], Debate
      can [:read, :map, :summary, :share], Proposal
      can :read, Comment

      can [:read, :welcome, :select_district], SpendingProposal
      can [:stats, :results], SpendingProposal

      can :read, Poll
      can :read, Poll::Question

      can [:read, :welcome], Budget
      can [:read, :print], Budget::Investment
      can [:read], Budget::Group

      can :read, Legislation
      can :read, User
      can [:search, :read], Annotation

      can :new, DirectMessage

      can :results_2017, Poll
      can :stats_2017, Poll
      can :info_2017, Poll
    end
  end
end
