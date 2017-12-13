class Budget
  class Investment
    class Milestone < ActiveRecord::Base
      include Imageable

      belongs_to :investment

      validates :title, presence: true
      validates :investment, presence: true
      validates :publication_date, presence: true

      def self.title_max_length
        80
      end
    end
  end
end
