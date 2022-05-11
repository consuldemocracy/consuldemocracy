class Investment
    class Budget::Investment::Answer < ApplicationRecord

      belongs_to :investment, touch: true
  
    end
  end
  