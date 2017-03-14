module Abilities
  class Valuator
    include CanCan::Ability

    def initialize(user)
      valuator = user.valuator
      can [:read, :update, :valuate], SpendingProposal
      can [:read, :update, :valuate], Budget::Investment, id: valuator.investment_ids
      cannot [:update, :valuate], Budget::Investment, budget: { phase: 'finished' }
      can :create, DirectMessage
      can :show, DirectMessage, sender_id: user.id
    end
  end
end
