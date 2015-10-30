module Abilities
  class Everyone
    include CanCan::Ability

    def initialize(user)
      can :read, Debate
      can :read, Medida
      can :read, Proposal
    end
  end
end
