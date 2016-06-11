class Budget
  class Ballot
    class Line < ActiveRecord::Base
      belongs_to :ballot
      belongs_to :budget
      belongs_to :group
      belongs_to :heading
      belongs_to :investment

      validates :ballot_id, :budget_id, :group_id, :heading_id, :investment_id, presence: true
    end
  end
end
