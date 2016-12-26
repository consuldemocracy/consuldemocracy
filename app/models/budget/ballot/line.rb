class Budget
  class Ballot
    class Line < ActiveRecord::Base
      belongs_to :ballot
      belongs_to :investment
      belongs_to :heading
      belongs_to :group
      belongs_to :budget

      validates :ballot_id, :investment_id, :heading_id, :group_id, :budget_id, presence: true

      validate :insufficient_funds
      #needed? validate :different_geozone, :if => :district_proposal?
      validate :unselected

      before_validation :set_denormalized_ids

      def insufficient_funds
        errors.add(:money, "insufficient funds") if ballot.amount_available(investment.heading) < investment.price.to_i
      end

      def different_geozone
        errors.add(:heading, "different heading assigned") if (ballot.heading.present? && investment.heading != ballot.heading)
      end

      def unselected
        errors.add(:investment, "unselected investment") unless investment.selected?
      end

      def heading_proposal?
        investment.heading_id.present?
      end

      private

        def set_denormalized_ids
          self.heading_id ||= self.investment.try(:heading_id)
          self.group_id   ||= self.investment.try(:group_id)
          self.budget_id  ||= self.investment.try(:budget_id)
        end
    end
  end
end
