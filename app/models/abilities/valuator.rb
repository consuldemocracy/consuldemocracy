module Abilities
  class Valuator
    include CanCan::Ability

    def initialize(user)
      can :read, SpendingProposal

      if Setting['feature.spending_proposal_features.valuation_allowed'].present?
        can [:update, :valuate], SpendingProposal
      end

      valuator = user.valuator
      can [:read], SpendingProposal
      can [:read, :update, :valuate], Budget::Investment, id: valuator.investment_ids
      cannot [:update, :valuate], Budget::Investment, budget: { phase: 'finished' }
    end
  end
end
