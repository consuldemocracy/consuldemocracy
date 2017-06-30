class Budget
  class Investment
    class Milestone < ApplicationRecord
      belongs_to :investment

      validates :title, presence: true
      validates :investment, presence: true

      def self.title_max_length
        80
      end
    end
  end
end
