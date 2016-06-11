class Budget
  class Ballot
    class Line < ActiveRecord::Base
      belongs_to :ballot
      belongs_to :budget
      belongs_to :group
      belongs_to :heading
      belongs_to :investment

      validates :ballot_id, :budget_id, :group_id, :heading_id, :investment_id, presence: true
      validate :insufficient_funds
      validate :unfeasible

      def insufficient_funds
        return unless errors.blank?
        errors.add(:money, "") if ballot.amount_available(heading) < investment.price.to_i
      end

      def unfeasible
        return unless errors.blank?
        errors.add(:unfeasible, "") unless investment.feasible?
      end

    end
  end
end
