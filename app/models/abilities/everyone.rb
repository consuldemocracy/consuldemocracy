module Abilities
  class Everyone
    include CanCan::Ability

    def initialize(user)
      can :read, Debate
      can :read, Proposal
      can :read, Legislation
      can :read, User
    end
  end
end
