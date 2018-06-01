class Budget::Investment::Status < ApplicationRecord
  acts_as_paranoid column: :hidden_at

  has_many :milestones

  validates :name, presence: true
end
