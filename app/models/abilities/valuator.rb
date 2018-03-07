module Abilities
  class Valuator
    include CanCan::Ability

    def initialize(user)
      valuator = user.valuator
      can [:read, :update, :valuate], SpendingProposal
      can [:read, :update, :valuate, :comment_valuation], Budget::Investment, id: valuator.investment_ids
      cannot [:update, :valuate, :comment_valuation], Budget::Investment, budget: { phase: 'finished' }
    end
  end
end
