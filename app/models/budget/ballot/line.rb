class Budget
  class Ballot
    class Line < ActiveRecord::Base
      belongs_to :ballot
      belongs_to :investment
    end
  end
end
