class Budget::Investment::Status < ActiveRecord::Base
  acts_as_paranoid column: :hidden_at

  has_many :milestones

  validates :name, presence: true
end
