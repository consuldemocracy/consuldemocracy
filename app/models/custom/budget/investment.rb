require_dependency Rails.root.join("app", "models", "budget", "investment").to_s
require "logger"
class Budget
  class Investment < ApplicationRecord
    has_many :physical_final_votes, as: :signable
	
    def permission_problem(user)
      return :not_logged_in unless user
      return :organization  if user.organization?
      return :not_verified  unless user.can?(:vote, Budget::Investment)
      return :user_locked if user_locked?(user)

      nil
    end

    def reason_for_not_being_ballotable_by(user, ballot)
      return permission_problem(user)    if permission_problem?(user)
      return :not_selected               unless selected?
      return :no_ballots_allowed         unless budget.balloting?
      return :different_heading_assigned unless ballot.valid_heading?(heading)
      return :not_enough_money           if ballot.present? && !enough_money?(ballot)
      return :casted_offline             if ballot.casted_offline?
      return :user_locked                if user_locked?(user)
    end

    def physical_final_votes_count
      physical_final_votes.to_a.sum(&:total_votes)
    end

    def final_total_votes
	
      ballot_lines_count + physical_final_votes_count
    end

    private

      def user_locked?(user)
        # Comprobar si está bloqueado sólo para voto presencial
        Budget::LockedUser.where(document_type: user.document_type)
                          .where(document_number: user.document_number)
                          .where(budget_id: budget_id)
                          .count >= 1
      end
  end
end
