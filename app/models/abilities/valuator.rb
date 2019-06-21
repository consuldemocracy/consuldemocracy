module Abilities
  class Valuator
    include CanCan::Ability

    def initialize(user)
      valuator = user.valuator
      assigned_investment_ids = valuator.assigned_investment_ids
      finished = { phase: "finished" }

      can [:read, :update], Budget::Investment, id: assigned_investment_ids
      can [:valuate], Budget::Investment, { id: assigned_investment_ids, valuation_finished: false }
      cannot [:update, :valuate, :comment_valuation], Budget::Investment, budget: finished

      if valuator.can_edit_dossier?
        can [:edit_dossier], Budget::Investment, id: assigned_investment_ids
      end

      if valuator.can_comment?
        can [:comment_valuation], Budget::Investment, id: assigned_investment_ids
      end
    end
  end
end
