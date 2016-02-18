module Abilities
  class Valuator
    include CanCan::Ability

    def initialize(user)
      can :manage, SpendingProposal
    end
  end
end