class Budget
  class Ballot
    class Line < ActiveRecord::Base
      belongs_to :ballot
      belongs_to :budget
      belongs_to :group
      belongs_to :heading
      belongs_to :investment

      validate :insufficient_funds
      #needed? validate :different_geozone, :if => :district_proposal?
      validate :unfeasible
      #needed? validates :ballot_id, :budget_id, :group_id, :heading_id, :investment_id, presence: true

      def insufficient_funds
        errors.add(:money, "insufficient funds") if ballot.amount_available(investment.heading) < investment.price.to_i
      end

      def different_geozone
        errors.add(:heading, "different heading assigned") if (ballot.heading.present? && investment.heading != ballot.heading)
      end

      def unfeasible
        errors.add(:unfeasible, "unfeasible investment") unless investment.feasible?
      end

      def heading_proposal?
        investment.heading_id.present?
      end
    end
  end
end
