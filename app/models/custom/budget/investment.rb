require_dependency Rails.root.join("app", "models", "budget", "investment").to_s

class Budget
  class Investment < ApplicationRecord
    def reason_for_not_being_ballotable_by(user, ballot)
      return permission_problem(user)    if permission_problem?(user)
      return :not_selected               unless selected?
      return :no_ballots_allowed         unless budget.balloting?
      return :invalid_geozone            unless ballotable_by_geozone?(user)
      return :different_heading_assigned unless ballot.valid_heading?(heading)
      return :not_enough_money           if ballot.present? && !enough_money?(ballot)
      return :casted_offline             if ballot.casted_offline?
    end

    def ballotable_by_geozone?(user)
      heading.geozone.blank? || heading.geozone == user.geozone
    end
  end
end
