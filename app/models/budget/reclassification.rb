class Budget
  module Reclassification
    extend ActiveSupport::Concern

    included do
      after_save :check_for_reclassification
    end

    def check_for_reclassification
      if saved_change_to_heading?
        log_heading_change
        store_reclassified_votes("heading_changed")
        remove_reclassified_votes
      elsif marked_as_unfeasible?
        store_reclassified_votes("unfeasible")
        remove_reclassified_votes
      end
    end

    def saved_change_to_heading?
      budget.balloting? && saved_change_to_heading_id?
    end

    def marked_as_unfeasible?
      budget.balloting? && saved_change_to_feasibility? && unfeasible?
    end

    def log_heading_change
      update_column(:previous_heading_id, heading_id_before_last_save)
    end

    def store_reclassified_votes(reason)
      ballot_lines_for_investment.order(:id).each do |line|
        attrs = { user: line.ballot.user, investment: self, reason: reason }
        Budget::ReclassifiedVote.create!(attrs)
      end
    end

    def remove_reclassified_votes
      ballot_lines_for_investment.destroy_all
    end

    def ballot_lines_for_investment
      Budget::Ballot::Line.by_investment(id)
    end
  end
end
