module Abilities
  class Valuator
    include CanCan::Ability

    def initialize(user)
      valuator = user.valuator

      can [:read, :update, :valuate], SpendingProposal
      can [:read, :update, :comment_valuation], Budget::Investment, id: valuator.assigned_investment_ids
      can [:valuate], Budget::Investment, { id: valuator.assigned_investment_ids, valuation_finished: false }
      cannot [:update, :valuate, :comment_valuation], Budget::Investment, budget: { phase: 'finished' }
      can :create, DirectMessage
      can :show, DirectMessage, sender_id: user.id
    end
  end
end
