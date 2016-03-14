module Abilities
  class Valuator
    include CanCan::Ability

    def initialize(user)
      can [:read, :update, :valuate], SpendingProposal
    end
  end
end