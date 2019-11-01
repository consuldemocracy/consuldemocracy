class Budget::Investment::ChangeLog < ApplicationRecord
  belongs_to :author, -> { with_hidden },
    class_name:  "User",
    foreign_key: "author_id",
    inverse_of:  :budget_investment_change_logs,
    required:    false

  validates :field, presence: true

  scope :by_investment, ->(investment_id) { where(investment_id: investment_id) }
end
