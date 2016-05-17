module Abilities
  class Valuator
    include CanCan::Ability

    def initialize(user)
      can :read, SpendingProposal

      if Setting['feature.spending_proposal_features.valuation_allowed'].present?
        can [:update, :valuate], SpendingProposal
      end

    end
  end
end