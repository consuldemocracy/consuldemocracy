class Budget::Investment::ChangeLog < ApplicationRecord
  belongs_to :author, -> { with_hidden }, class_name: "User", foreign_key: "author_id", required: false

  validates :old_value, presence: true
  validates :new_value, presence: true
  validates :field, presence: true

  scope :by_investment,     ->(investment_id) { where(investment_id: investment_id) }

end
