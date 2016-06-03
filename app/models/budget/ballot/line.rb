class Budget
  class Ballot
    class Line < ActiveRecord::Base
      belongs_to :ballot
      belongs_to :investment

      validate :insufficient_funds
      validate :different_geozone, :if => :district_proposal?
      validate :unfeasible

      def insufficient_funds
        errors.add(:money, "") if ballot.amount_available(investment.heading) < investment.price.to_i
      end

      def different_geozone
        errors.add(:heading, "") if (ballot.heading.present? && investment.heading != ballot.heading)
      end

      def unfeasible
        errors.add(:unfeasible, "") unless investment.feasible?
      end

      def heading_proposal?
        investment.heading_id.present?
      end

    end
  end
end
