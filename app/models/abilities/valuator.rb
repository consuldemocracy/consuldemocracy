module Abilities
  class Valuator
    include CanCan::Ability

    def initialize(user)
      if Setting['feature.spending_proposal_features.valuation_allowed'].present?
        can [:read, :update, :valuate], SpendingProposal
      end
    end
  end
end