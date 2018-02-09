module Abilities
  class Valuator
    include CanCan::Ability

    def initialize(user)
      valuator = user.valuator
      can [:read, :update, :valuate], SpendingProposal
      can [:read, :update, :comment_valuation], Budget::Investment, id: valuator.investment_ids + valuator.valuator_group.investment_ids
      can [:valuate], Budget::Investment, { id: valuator.investment_ids + valuator.valuator_group.investment_ids, valuation_finished: false }
      cannot [:update, :valuate, :comment_valuation], Budget::Investment, budget: { phase: 'finished' }
    end
  end
end
