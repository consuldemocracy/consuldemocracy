require_dependency Rails.root.join('app', 'models', 'budget', 'investment').to_s

class Budget
  class Investment < ApplicationRecord

    has_many :answers, class_name: "Investment::Answer"
    accepts_nested_attributes_for :answers

    validates_translation :description, presence: false, length: { maximum: Budget::Investment.description_max_length }

    # this is quite possibly useless and/or redundant
    def self.description
      unless self.budget.questions.any? do
        self.description
      end

      return 'OPIS MANJKA UPS'
    end

  end
end
end