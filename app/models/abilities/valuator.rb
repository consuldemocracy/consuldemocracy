module Abilities
  class Valuator
    include CanCan::Ability

    def initialize(user)
      valuator = user.valuator
      assigned_investment_ids = valuator.assigned_investment_ids

      can [:read], Budget::Investment, id: assigned_investment_ids
      can [:valuate], Budget::Investment, { id: assigned_investment_ids, valuation_finished: false }

      if valuator.can_edit_dossier?
        can [:edit_dossier], Budget::Investment, id: assigned_investment_ids
      end

      if valuator.can_comment?
        can [:comment_valuation], Budget::Investment, id: assigned_investment_ids
      end

      cannot [:valuate, :edit_dossier, :comment_valuation], Budget::Investment, budget: { phase: "finished" }
    end
  end
end
