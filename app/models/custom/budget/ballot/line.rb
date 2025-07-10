require_dependency Rails.root.join("app", "models", "budget", "ballot", "line").to_s

class Budget
  class Ballot
    class Line < ApplicationRecord
      validate :check_user_locked?

      def check_user_locked?
        user = self.ballot.user
        budget_id = self.investment.budget_id

        if Budget::LockedUser.where(document_number: user.document_number, document_type: user.document_type, budget_id: budget_id).exists?
          errors.add(:investment, I18n.t("errors.budget.locked_user"))
        end
      end
    end
  end
end
