class Budget
    class Question < ApplicationRecord
      translates :text, touch: true
      include Globalizable
  
      belongs_to :budget, touch: true

      validates_translation :text, presence: true
    
      scope :enabled, -> { where(enabled: true) }

      private
  
    end
  end
  