class Budget
  class Investment
    class Checkpoint < ActiveRecord::Base
      belongs_to :investment

      validates :title, presence: true
      validates :investment, presence: true
    end
  end
end
